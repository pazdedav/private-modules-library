# VMs and Load Balancer

VNet with internal load balancer and VMs and Bastion Host

!!! info "Module reference (latest tag)"
    ```
    br:modlibbicepreg.azurecr.io/modules/ptn/nic20204:0.1.0
    ```

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
adminUsername  | Yes      | Admin username
adminPassword  | Yes      | Admin password
vmNamePrefix   | No       | Prefix to use for VM names
location       | No       | Location for all resources.
vmSize         | No       | Size of VM
vNetAddressPrefix | No       | Virtual network address prefix
vNetSubnetAddressPrefix | No       | Backend subnet address prefix
vNetBastionSubnetAddressPrefix | No       | Bastion subnet address prefix

### adminUsername

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Admin username

### adminPassword

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Admin password

### vmNamePrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Prefix to use for VM names

- Default value: `BackendVM`

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Location for all resources.

- Default value: `[resourceGroup().location]`

### vmSize

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Size of VM

- Default value: `Standard_D2s_v3`

### vNetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Virtual network address prefix

- Default value: `10.0.0.0/16`

### vNetSubnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Backend subnet address prefix

- Default value: `10.0.0.0/24`

### vNetBastionSubnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Bastion subnet address prefix

- Default value: `10.0.2.0/24`

## Outputs

Name | Type | Description
---- | ---- | -----------
location | string |
name | string |
resourceGroupName | string |
resourceId | string |

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "modules/ptn/nic20204/deploy.json"
    },
    "parameters": {
        "adminUsername": {
            "value": ""
        },
        "adminPassword": {
            "reference": {
                "keyVault": {
                    "id": ""
                },
                "secretName": ""
            }
        },
        "vmNamePrefix": {
            "value": "BackendVM"
        },
        "location": {
            "value": "[resourceGroup().location]"
        },
        "vmSize": {
            "value": "Standard_D2s_v3"
        },
        "vNetAddressPrefix": {
            "value": "10.0.0.0/16"
        },
        "vNetSubnetAddressPrefix": {
            "value": "10.0.0.0/24"
        },
        "vNetBastionSubnetAddressPrefix": {
            "value": "10.0.2.0/24"
        }
    }
}
```


