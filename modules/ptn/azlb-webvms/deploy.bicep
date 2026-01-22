metadata name = 'VMs and Load Balancer'
metadata description = 'VNet with internal load balancer and VMs and Bastion Host'
targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('Prefix to use for VM names')
param vmNamePrefix string = 'BackendVM'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of VM')
param vmSize string = 'Standard_D2s_v3'

@description('Virtual network address prefix')
param vNetAddressPrefix string = '10.0.0.0/16'

@description('Backend subnet address prefix')
param vNetSubnetAddressPrefix string = '10.0.0.0/24'

@description('Bastion subnet address prefix')
param vNetBastionSubnetAddressPrefix string = '10.0.2.0/24'

// =========== //
// Variable declaration //
// =========== //

var natGatewayName = 'lb-nat-gateway'
var vNetName = 'lb-vnet'
var vNetSubnetName = 'backend-subnet'
var storageAccountName = uniqueString(resourceGroup().id)
var loadBalancerName = 'internal-lb'
var numberOfInstances = 2
var bastionName = 'lb-bastion'
var bastionSubnetName = 'AzureBastionSubnet'

// =========== //
// Resources and Modules //
// =========== //

module natGateway 'br/public:avm/res/network/nat-gateway:1.2.1' = {
  name: '${uniqueString(deployment().name, location)}-NatGateway'
  params: {
    name: natGatewayName
    zone: 1
    idleTimeoutInMinutes: 4
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: '${uniqueString(deployment().name, location)}-VirtualNetwork'
  params: {
    name: vNetName
    addressPrefixes: [
      vNetAddressPrefix
    ]
    subnets: [
      {
        addressPrefix: vNetBastionSubnetAddressPrefix
        name: bastionSubnetName
      }
      {
        addressPrefix: vNetSubnetAddressPrefix
        name: vNetSubnetName
        natGatewayResourceId: natGateway.outputs.resourceId
      }
    ]
  }
}

module bastionHost 'br/public:avm/res/network/bastion-host:0.5.0' = {
  name: '${uniqueString(deployment().name, location)}-BastionHost'
  params: {
    name: bastionName
    location: location
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
  }
}

module intLoadBalancer 'br/public:avm/res/network/load-balancer:0.4.0' = {
  name: '${uniqueString(deployment().name, location)}-LoadBalancer'
  params: {
    name: loadBalancerName
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        subnetId: virtualNetwork.outputs.subnetResourceIds[1]
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    loadBalancingRules: [
      {
        backendAddressPoolName: 'BackendPool1'
        backendPort: 80
        disableOutboundSnat: true
        enableFloatingIP: true
        enableTcpReset: false
        frontendIPConfigurationName: 'LoadBalancerFrontend'
        frontendPort: 80
        idleTimeoutInMinutes: 15
        loadDistribution: 'Default'
        name: 'lbrule'
        probeName: 'lbprobe'
        protocol: 'Tcp'
      }
    ]
    probes: [
      {
        intervalInSeconds: 15
        name: 'lbprobe'
        numberOfProbes: 2
        port: '80'
        protocol: 'Tcp'
      }
    ]
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.14.3' = {
  name: '${uniqueString(deployment().name, location)}-StorageAccount'
  params: {
    name: storageAccountName
    location: location
    kind: 'StorageV2'
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.5.3' = [
  for i in range(0, numberOfInstances): {
    name: '${uniqueString(deployment().name, location)}-virtualMachine${i}'
    params: {
      name: '${vmNamePrefix}${i}'
      adminUsername: adminUsername
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      nicConfigurations: [
        {
          ipConfigurations: [
            {
              name: 'ipconfig01'
              subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
            }
          ]
          nicSuffix: '-nic-${i}'
          loadBalancerBackendAddressPools: [
            {
              id: intLoadBalancer.outputs.resourceId
            }
          ]
        }
      ]
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      osType: 'Windows'
      vmSize: vmSize
      zone: 0
      adminPassword: adminPassword
      location: location
    }
  }
]

// =========== //
// Outputs     //
// =========== //

output location string = location
output name string = intLoadBalancer.name
output resourceGroupName string = resourceGroup().name
output resourceId string = intLoadBalancer.outputs.resourceId

// =========== //
// Types       //
// =========== //
