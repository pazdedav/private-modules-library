metadata name = 'Azure VM Scale Set behind Public Load Balancer'
metadata description = 'This pattern module deploys an Azure VM Scale Set behind a public load balancer with outbound internet connectivity through NAT Gateway.'

targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@description('Required. The name of the VM Scale Set.')
param vmssName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. Administrator username for the VM Scale Set instances.')
@secure()
param adminUsername string

@description('Required. Administrator password for the VM Scale Set instances.')
@secure()
param adminPassword string

@description('Optional. The VM SKU size for the scale set instances.')
param vmSize string = 'Standard_D2s_v5'

@description('Optional. The initial instance count for the VM Scale Set.')
@minValue(1)
@maxValue(100)
param instanceCount int = 2

@description('Optional. The OS type for the VM Scale Set.')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Windows'

@description('Optional. The image reference for the VM Scale Set.')
param imageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
  version: 'latest'
}

@description('Optional. Address prefix for the virtual network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Optional. Address prefix for the VMSS subnet.')
param vmssSubnetAddressPrefix string = '10.0.1.0/24'

@description('Optional. Address prefix for the NAT Gateway subnet.')
param natGatewaySubnetAddressPrefix string = '10.0.0.0/24'

@description('Optional. Tags to apply to all resources.')
param tags object = {}

// =========== //
// Variable declaration //
// =========== //

var publicIPName = '${vmssName}-pip'
var loadBalancerName = '${vmssName}-lb'
var vnetName = '${vmssName}-vnet'
var natGatewayName = '${vmssName}-natgw'

// =========== //
// Resources and Modules //
// =========== //

// Public IP for Load Balancer
module publicIP 'br/public:avm/res/network/public-ip-address:0.12.0' = {
  name: '${uniqueString(deployment().name, location)}-PublicIP'
  params: {
    name: publicIPName
    location: location
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    availabilityZones: [
      1
      2
      3
    ]
    tags: tags
  }
}

// NAT Gateway for outbound connectivity
module natGateway 'br/public:avm/res/network/nat-gateway:2.0.0' = {
  name: '${uniqueString(deployment().name, location)}-NatGateway'
  params: {
    name: natGatewayName
    location: location
    availabilityZone: 1
    tags: tags
  }
}

// Virtual Network
module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: '${uniqueString(deployment().name, location)}-VNet'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: 'NatGatewaySubnet'
        addressPrefix: natGatewaySubnetAddressPrefix
        natGatewayResourceId: natGateway.outputs.resourceId
      }
      {
        name: 'VmssSubnet'
        addressPrefix: vmssSubnetAddressPrefix
        natGatewayResourceId: natGateway.outputs.resourceId
      }
    ]
    tags: tags
  }
}

// Public Load Balancer
module publicLoadBalancer 'br/public:avm/res/network/load-balancer:0.7.0' = {
  name: '${uniqueString(deployment().name, location)}-LoadBalancer'
  params: {
    name: loadBalancerName
    location: location
    skuName: 'Standard'
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        publicIPAddressResourceId: publicIP.outputs.resourceId
      }
    ]
    backendAddressPools: [
      {
        name: 'VmssBackendPool'
      }
    ]
    loadBalancingRules: [
      {
        name: 'HttpRule'
        frontendIPConfigurationName: 'LoadBalancerFrontend'
        backendAddressPoolName: 'VmssBackendPool'
        frontendPort: 80
        backendPort: 80
        protocol: 'Tcp'
        probeName: 'HttpProbe'
        idleTimeoutInMinutes: 15
        enableFloatingIP: false
        enableTcpReset: true
        disableOutboundSnat: true
      }
    ]
    probes: [
      {
        name: 'HttpProbe'
        protocol: 'Http'
        port: 80
        requestPath: '/'
        intervalInSeconds: 15
        numberOfProbes: 2
      }
    ]
    tags: tags
  }
}

// VM Scale Set
module vmss 'br/public:avm/res/compute/virtual-machine-scale-set:0.11.0' = {
  name: '${uniqueString(deployment().name, location)}-VMSS'
  params: {
    name: vmssName
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    skuName: vmSize
    skuCapacity: instanceCount
    osType: osType
    imageReference: imageReference
    orchestrationMode: 'Uniform'
    upgradePolicyMode: 'Automatic'
    nicConfigurations: [
      {
        name: 'VmssNic'
        enableAcceleratedNetworking: false
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
            loadBalancerBackendAddressPools: [
              {
                id: publicLoadBalancer.outputs.backendpools[0].id
              }
            ]
          }
        ]
      }
    ]
    osDisk: {
      createOption: 'FromImage'
      diskSizeGB: 128
      caching: 'ReadWrite'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    extensionHealthConfig: {
      enabled: true
      protocol: 'http'
      port: 80
      requestPath: '/'
    }
    bootDiagnosticEnabled: true
    availabilityZones: [
      1
      2
      3
    ]
    zoneBalance: true
    tags: tags
  }
}

// =========== //
// Outputs     //
// =========== //

@description('The name of the VM Scale Set.')
output vmssName string = vmss.outputs.name

@description('The resource ID of the VM Scale Set.')
output vmssResourceId string = vmss.outputs.resourceId

@description('The name of the public load balancer.')
output loadBalancerName string = publicLoadBalancer.outputs.name

@description('The resource ID of the public load balancer.')
output loadBalancerResourceId string = publicLoadBalancer.outputs.resourceId

@description('The public IP address of the load balancer.')
output publicIPAddress string = publicIP.outputs.ipAddress

@description('The name of the virtual network.')
output vnetName string = virtualNetwork.outputs.name

@description('The resource ID of the virtual network.')
output vnetResourceId string = virtualNetwork.outputs.resourceId

@description('The location of the deployed resources.')
output location string = location

@description('The resource group name.')
output resourceGroupName string = resourceGroup().name

// =========== //
// Types       //
// =========== //

// Published to ACR registry
