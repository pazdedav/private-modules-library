# Azure VM Scale Set behind Public Load Balancer

This pattern module deploys an Azure VM Scale Set behind a public load balancer with outbound internet connectivity through NAT Gateway.

!!! info "Module reference (latest tag)"
    ```
    br:modlibbicepreg.azurecr.io/modules/ptn/m365con:0.1.0
    ```

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
vmssName       | Yes      | Required. The name of the VM Scale Set.
location       | No       | Optional. Location for all resources.
adminUsername  | Yes      | Required. Administrator username for the VM Scale Set instances.
adminPassword  | Yes      | Required. Administrator password for the VM Scale Set instances.
vmSize         | No       | Optional. The VM SKU size for the scale set instances.
instanceCount  | No       | Optional. The initial instance count for the VM Scale Set.
osType         | No       | Optional. The OS type for the VM Scale Set.
imageReference | No       | Optional. The image reference for the VM Scale Set.
vnetAddressPrefix | No       | Optional. Address prefix for the virtual network.
vmssSubnetAddressPrefix | No       | Optional. Address prefix for the VMSS subnet.
natGatewaySubnetAddressPrefix | No       | Optional. Address prefix for the NAT Gateway subnet.
tags           | No       | Optional. Tags to apply to all resources.

### vmssName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Required. The name of the VM Scale Set.

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Location for all resources.

- Default value: `[resourceGroup().location]`

### adminUsername

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Required. Administrator username for the VM Scale Set instances.

### adminPassword

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Required. Administrator password for the VM Scale Set instances.

### vmSize

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. The VM SKU size for the scale set instances.

- Default value: `Standard_D2s_v5`

### instanceCount

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. The initial instance count for the VM Scale Set.

- Default value: `2`

### osType

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. The OS type for the VM Scale Set.

- Default value: `Windows`

- Allowed values: `Windows`, `Linux`

### imageReference

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. The image reference for the VM Scale Set.

- Default value: `@{publisher=MicrosoftWindowsServer; offer=WindowsServer; sku=2022-datacenter-azure-edition; version=latest}`

### vnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Address prefix for the virtual network.

- Default value: `10.0.0.0/16`

### vmssSubnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Address prefix for the VMSS subnet.

- Default value: `10.0.1.0/24`

### natGatewaySubnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Address prefix for the NAT Gateway subnet.

- Default value: `10.0.0.0/24`

### tags

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Tags to apply to all resources.

## Outputs

Name | Type | Description
---- | ---- | -----------
vmssName | string | The name of the VM Scale Set.
vmssResourceId | string | The resource ID of the VM Scale Set.
loadBalancerName | string | The name of the public load balancer.
loadBalancerResourceId | string | The resource ID of the public load balancer.
publicIPAddress | string | The public IP address of the load balancer.
vnetName | string | The name of the virtual network.
vnetResourceId | string | The resource ID of the virtual network.
location | string | The location of the deployed resources.
resourceGroupName | string | The resource group name.

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "modules/ptn/m365con/deploy.json"
    },
    "parameters": {
        "vmssName": {
            "value": ""
        },
        "location": {
            "value": "[resourceGroup().location]"
        },
        "adminUsername": {
            "reference": {
                "keyVault": {
                    "id": ""
                },
                "secretName": ""
            }
        },
        "adminPassword": {
            "reference": {
                "keyVault": {
                    "id": ""
                },
                "secretName": ""
            }
        },
        "vmSize": {
            "value": "Standard_D2s_v5"
        },
        "instanceCount": {
            "value": 2
        },
        "osType": {
            "value": "Windows"
        },
        "imageReference": {
            "value": {
                "publisher": "MicrosoftWindowsServer",
                "offer": "WindowsServer",
                "sku": "2022-datacenter-azure-edition",
                "version": "latest"
            }
        },
        "vnetAddressPrefix": {
            "value": "10.0.0.0/16"
        },
        "vmssSubnetAddressPrefix": {
            "value": "10.0.1.0/24"
        },
        "natGatewaySubnetAddressPrefix": {
            "value": "10.0.0.0/24"
        },
        "tags": {
            "value": {}
        }
    }
}
```


