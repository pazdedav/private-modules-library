# AVD - Management Plane

This module deploys a AVD management Plane

!!! info "Module reference (latest tag)"
    ```
    br:modlibbicepreg.azurecr.io/modules/ptn/avdmanagementplane:0.1.0
    ```

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
managementPlaneLocation | Yes      | Location where to deploy AVD management plane.
workloadSubsId | Yes      | AVD workload subscription ID, multiple subscriptions scenario.
computeTimeZone | Yes      | Virtual machine time zone.
identityServiceProvider | Yes      | The service providing domain services for Azure Virtual Desktop.
serviceObjectsRgName | Yes      | AVD Resource Group Name for the service objects.
deployScalingPlan | Yes      | AVD deploy scaling plan.
hostPoolName   | Yes      | AVD Host Pool Name
hostPoolFriendlyName | Yes      | AVD Host Pool friendly Name
scalingPlanName | Yes      | AVD scaling plan name
scalingPlanSchedules | Yes      | AVD scaling plan schedules
workSpaceName  | Yes      | AVD workspace name.
workSpaceFriendlyName | Yes      | AVD workspace friendly name.
hostPoolRdpProperties | Yes      | AVD host pool Custom RDP properties.
hostPoolType   | Yes      | Optional. AVD host pool type.
preferredAppGroupType | No       | Optional. The type of preferred application group type, default to Desktop Application Group.
personalAssignType | Yes      | Optional. AVD host pool type.
hostPoolLoadBalancerType | Yes      | AVD host pool load balacing type.
hostPoolMaxSessions | Yes      | Optional. AVD host pool maximum number of user sessions per session host.
startVmOnConnect | Yes      | Optional. AVD host pool start VM on Connect.
hostPoolAgentUpdateSchedule | Yes      | Optional. AVD host pool start VM on Connect.
tags           | Yes      | Tags to be applied to resources
scalingPlanExclusionTag | Yes      | Tag to exclude resources from scaling plan.
alaWorkspaceResourceId | Yes      | Log analytics workspace for diagnostic logs.
time           | No       | Do not modify, used to set unique value for resource deployment.
applicationGroupsList | No       | Optional. Array of application groups to be created.
useVarRAppApplicationGroupsStandardApps | No       | Optional. Array of applications to be created.
useVarRAppApplicationGroupsOfficeApps | No       | Optional. Array of applications to be created.

### managementPlaneLocation

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Location where to deploy AVD management plane.

### workloadSubsId

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD workload subscription ID, multiple subscriptions scenario.

### computeTimeZone

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Virtual machine time zone.

### identityServiceProvider

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The service providing domain services for Azure Virtual Desktop.

### serviceObjectsRgName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD Resource Group Name for the service objects.

### deployScalingPlan

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD deploy scaling plan.

### hostPoolName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD Host Pool Name

### hostPoolFriendlyName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD Host Pool friendly Name

### scalingPlanName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD scaling plan name

### scalingPlanSchedules

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD scaling plan schedules

### workSpaceName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD workspace name.

### workSpaceFriendlyName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD workspace friendly name.

### hostPoolRdpProperties

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD host pool Custom RDP properties.

### hostPoolType

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Optional. AVD host pool type.

- Allowed values: `Personal`, `Pooled`

### preferredAppGroupType

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. The type of preferred application group type, default to Desktop Application Group.

- Default value: `Desktop`

- Allowed values: `Desktop`, `None`, `RailApplications`

### personalAssignType

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Optional. AVD host pool type.

- Allowed values: `Automatic`, `Direct`

### hostPoolLoadBalancerType

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD host pool load balacing type.

- Allowed values: `BreadthFirst`, `DepthFirst`

### hostPoolMaxSessions

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Optional. AVD host pool maximum number of user sessions per session host.

### startVmOnConnect

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Optional. AVD host pool start VM on Connect.

### hostPoolAgentUpdateSchedule

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Optional. AVD host pool start VM on Connect.

### tags

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Tags to be applied to resources

### scalingPlanExclusionTag

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Tag to exclude resources from scaling plan.

### alaWorkspaceResourceId

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Log analytics workspace for diagnostic logs.

### time

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Do not modify, used to set unique value for resource deployment.

- Default value: `[utcNow()]`

### applicationGroupsList

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Array of application groups to be created.

### useVarRAppApplicationGroupsStandardApps

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Array of applications to be created.

- Default value: `False`

### useVarRAppApplicationGroupsOfficeApps

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Optional. Array of applications to be created.

- Default value: `False`

## Outputs

Name | Type | Description
---- | ---- | -----------
hostPoolResourceId | string | The resource Id of the host pool.

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "modules/ptn/avdManagementPlane/deploy.json"
    },
    "parameters": {
        "managementPlaneLocation": {
            "value": ""
        },
        "workloadSubsId": {
            "value": ""
        },
        "computeTimeZone": {
            "value": ""
        },
        "identityServiceProvider": {
            "value": ""
        },
        "serviceObjectsRgName": {
            "value": ""
        },
        "deployScalingPlan": {
            "value": null
        },
        "hostPoolName": {
            "value": ""
        },
        "hostPoolFriendlyName": {
            "value": ""
        },
        "scalingPlanName": {
            "value": ""
        },
        "scalingPlanSchedules": {
            "value": []
        },
        "workSpaceName": {
            "value": ""
        },
        "workSpaceFriendlyName": {
            "value": ""
        },
        "hostPoolRdpProperties": {
            "value": ""
        },
        "hostPoolType": {
            "value": ""
        },
        "preferredAppGroupType": {
            "value": "Desktop"
        },
        "personalAssignType": {
            "value": ""
        },
        "hostPoolLoadBalancerType": {
            "value": ""
        },
        "hostPoolMaxSessions": {
            "value": 0
        },
        "startVmOnConnect": {
            "value": null
        },
        "hostPoolAgentUpdateSchedule": {
            "value": []
        },
        "tags": {
            "value": {}
        },
        "scalingPlanExclusionTag": {
            "value": ""
        },
        "alaWorkspaceResourceId": {
            "value": ""
        },
        "time": {
            "value": "[utcNow()]"
        },
        "applicationGroupsList": {
            "value": []
        },
        "useVarRAppApplicationGroupsStandardApps": {
            "value": false
        },
        "useVarRAppApplicationGroupsOfficeApps": {
            "value": false
        }
    }
}
```


