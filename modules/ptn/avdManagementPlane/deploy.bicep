metadata name = 'AVD - Management Plane'
metadata description = 'This module deploys a AVD management Plane'
targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('Virtual machine time zone.')
param computeTimeZone string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD deploy scaling plan.')
param deployScalingPlan bool

@sys.description('AVD Host Pool Name')
param hostPoolName string

@sys.description('AVD Host Pool friendly Name')
param hostPoolFriendlyName string

@sys.description('AVD scaling plan name')
param scalingPlanName string

@sys.description('AVD scaling plan schedules')
param scalingPlanSchedules array

@sys.description('AVD workspace name.')
param workSpaceName string

@sys.description('AVD workspace friendly name.')
param workSpaceFriendlyName string

@sys.description('AVD host pool Custom RDP properties.')
param hostPoolRdpProperties string

@allowed([
  'Personal'
  'Pooled'
])
@sys.description('Optional. AVD host pool type.')
param hostPoolType string

@sys.description('Optional. The type of preferred application group type, default to Desktop Application Group.')
@allowed([
  'Desktop'
  'None'
  'RailApplications'
])
param preferredAppGroupType string = 'Desktop'

@allowed([
  'Automatic'
  'Direct'
])
@sys.description('Optional. AVD host pool type.')
param personalAssignType string

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@sys.description('AVD host pool load balacing type.')
param hostPoolLoadBalancerType string

@sys.description('Optional. AVD host pool maximum number of user sessions per session host.')
param hostPoolMaxSessions int

@sys.description('Optional. AVD host pool start VM on Connect.')
param startVmOnConnect bool

@sys.description('Optional. AVD host pool start VM on Connect.')
param hostPoolAgentUpdateSchedule array

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Tag to exclude resources from scaling plan.')
param scalingPlanExclusionTag string

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Optional. Array of application groups to be created.')
param applicationGroupsList applicationGroupType = []

@sys.description('Optional. Array of applications to be created.')
param useVarRAppApplicationGroupsStandardApps bool = false

@sys.description('Optional. Array of applications to be created.')
param useVarRAppApplicationGroupsOfficeApps bool = false


// =========== //
// Variable declaration //
// =========== //

var varHostPoolRdpPropertiesDomainServiceCheck = (identityServiceProvider == 'EntraID') ? '${hostPoolRdpProperties};targetisaadjoined:i:1;enablerdsaadauth:i:1' : hostPoolRdpProperties
var varRAppApplicationGroupsStandardApps = (preferredAppGroupType == 'RailApplications') ? [
  {
    name: 'Task Manager'
    description: 'Task Manager'
    friendlyName: 'Task Manager'
    showInPortal: true
    filePath: 'C:\\Windows\\system32\\taskmgr.exe'
  }
  {
    name: 'WordPad'
    description: 'WordPad'
    friendlyName: 'WordPad'
    showInPortal: true
    filePath: 'C:\\Program Files\\Windows NT\\Accessories\\wordpad.exe'
  }
  {
    name: 'Microsoft Edge'
    description: 'Microsoft Edge'
    friendlyName: 'Edge'
    showInPortal: true
    filePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
  }
  {
    name: 'Remote Desktop Connection'
    description: 'Remote Desktop Connection'
    friendlyName: 'Remote Desktop'
    showInPortal: true
    filePath: 'C:\\WINDOWS\\system32\\mtsc.exe'
  }
] : []
var varRAppApplicationGroupsOfficeApps = (preferredAppGroupType == 'RailApplications') ? [
  {
    name: 'Microsoft Excel'
    description: 'Microsoft Excel'
    friendlyName: 'Excel'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE'
  }
  {
    name: 'Microsoft PowerPoint'
    description: 'Microsoft PowerPoint'
    friendlyName: 'PowerPoint'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE'
  }
  {
    name: 'Microsoft Word'
    description: 'Microsoft Word'
    friendlyName: 'Outlook'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE'
  }
  {
    name: 'Microsoft Outlook'
    description: 'Microsoft Word'
    friendlyName: 'Word'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE'
  }
] : []

var applicationGroupCustomApplications = useVarRAppApplicationGroupsOfficeApps ? varRAppApplicationGroupsOfficeApps : []
var applicationGroupAnotherApp = useVarRAppApplicationGroupsStandardApps ? varRAppApplicationGroupsStandardApps : []

var varHostPoolDiagnostic = [
  { categoryGroup: 'allLogs' }
]

var varApplicationGroupDiagnostic = [
  { categoryGroup: 'allLogs' }
]

var varWorkspaceDiagnostic = [
  { categoryGroup: 'allLogs' }
]

var varScalingPlanDiagnostic = [
  { categoryGroup: 'allLogs' }
]


// =========== //
// Deployments Commercial//
// =========== //


// Hostpool.
module hostPool 'br/public:avm/res/desktop-virtualization/host-pool:0.3.0' = {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'HostPool-${time}'
  params: {
    name: hostPoolName
    friendlyName: hostPoolFriendlyName
    location: managementPlaneLocation
    hostPoolType: hostPoolType
    startVMOnConnect: startVmOnConnect
    customRdpProperty: varHostPoolRdpPropertiesDomainServiceCheck
    loadBalancerType: hostPoolLoadBalancerType
    maxSessionLimit: hostPoolMaxSessions
    preferredAppGroupType: preferredAppGroupType
    personalDesktopAssignmentType: personalAssignType
    tags: tags
    diagnosticSettings: [
    {
      name: 'customSetting'
      workspaceResourceId: alaWorkspaceResourceId
      logCategoriesAndGroups: varHostPoolDiagnostic
    }
    ]
    agentUpdate: !empty(hostPoolAgentUpdateSchedule) ? {
      maintenanceWindows: hostPoolAgentUpdateSchedule
      maintenanceWindowTimeZone: computeTimeZone
      type: 'Scheduled'
      useSessionHostLocalTime: true
    } : {}
  }
}

// Application groups.
module applicationGroups 'br/public:avm/res/desktop-virtualization/application-group:0.2.0' = [
  for applicationGroup in applicationGroupsList: {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: '${applicationGroup.name}-${time}'
  params: {
    name: applicationGroup.name
    friendlyName: applicationGroup.friendlyName
    location: applicationGroup.location
    applicationGroupType: applicationGroup.applicationGroupType
    hostpoolName: hostPoolName
    tags: tags
    diagnosticSettings: [
      {
        name: 'customSetting'
        workspaceResourceId: alaWorkspaceResourceId
        logCategoriesAndGroups: varApplicationGroupDiagnostic
      }
    ]
    applications: (applicationGroup.applicationGroupType == 'RemoteApp') ?  union(applicationGroupCustomApplications, applicationGroupAnotherApp, applicationGroup.customApplications ?? []) : []
    roleAssignments: [for securityPrincipalGroup in applicationGroup.securityPrincipalGroups ?? [] : {
      roleDefinitionIdOrName: 'Desktop Virtualization User'
      principalId: securityPrincipalGroup.securityPrincipalId
      principalType: 'Group'
    }]
  }
  dependsOn: [
    hostPool
  ]
}
]


// Workspace.
module workSpace 'br/public:avm/res/desktop-virtualization/workspace:0.5.0' = {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Workspace-${time}'
  params: {
    name: workSpaceName
    friendlyName: workSpaceFriendlyName
    location: managementPlaneLocation
    applicationGroupReferences: [for applicationGroup in applicationGroupsList: '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroup.name}']
    tags: tags
    diagnosticSettings: [
      {
        name: 'customSetting'
        workspaceResourceId: alaWorkspaceResourceId
        logCategoriesAndGroups: varWorkspaceDiagnostic
      }
    ]
  }
  dependsOn: [
    hostPool
    applicationGroups
  ]
}

// Scaling plan.
module scalingPlan 'br/public:avm/res/desktop-virtualization/scaling-plan:0.2.0' = if (deployScalingPlan && (hostPoolType == 'Pooled')) {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Scaling-Plan-${time}'
  params: {
    name: scalingPlanName
    location: managementPlaneLocation
    hostPoolType: 'Pooled' //avdHostPoolType
    exclusionTag: scalingPlanExclusionTag
    timeZone: computeTimeZone
    schedules: scalingPlanSchedules
    hostPoolReferences: [
      {
        hostPoolArmPath: '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${hostPoolName}'
        scalingPlanEnabled: true
      }
    ]
    tags: tags
    diagnosticSettings: [
      {
        name: 'customSetting'
        workspaceResourceId: alaWorkspaceResourceId
        logCategoriesAndGroups: varScalingPlanDiagnostic
      }
    ]
  }
  dependsOn: [
    hostPool
    applicationGroups
    workSpace
  ]
}

// =========== //
// Outputs     //
// =========== //

@sys.description('The resource Id of the host pool.')
output hostPoolResourceId string = hostPool.outputs.resourceId

// =========== //
// Types       //
// =========== //

type appType = {
  @description('Required. Specify the name of the application')
  name: string

  @description('Optional. Resource Type of Application. (Inbuilt | MsixApplication)')
  applicationType: string?

  @description('Optional. Command Line Arguments for Application.')
  commandLineArguments: string?

  @description('Required. Specifies whether this published application can be launched with command line arguments provided by the client, command line arguments specified at publish time, or no command line arguments at all. (Allowed, DoNotAllow, Require) ')
  commandLineSetting: string

  @description('Optional. The description of the application')
  description: string?

  @description('Required. Friendly name of Application.')
  friendlyName: string

  @description('Required. Specifies whether to show the RemoteApp program in the RD Web Access server.')
  showInPortal: bool

  @description('Optional. Index of the icon.')
  iconIndex: int?

  @description('Optional. Path to icon')
  iconPath: string?

  @description('Optional. Specifies the package application Id for MSIX applications')
  msixPackageApplicationId: string?

  @description('Optional. Specifies the package family name for MSIX applications')
  msixPackageFamilyName: string?

  @description('Required. Specifies a path for the executable file for the application.')
  filePath: string
}[]?

type applicationGroupType = {
  @description('Required. The name of the application group.')
  name: string
  @description('Required. The friendly name of the application group.')
  friendlyName: string
  @description('Required. The location of the application group.')
  location: string
  @description('Required. The type of the application group. (Desktop | RemoteApp)')
  applicationGroupType: ('Desktop' | 'RemoteApp')
  @description('Optional. The list of applications to be added to the application group.')
  securityPrincipalGroups: securityPrincipalGroupsType
  @description('Optional. The list of applications to be added to the application group.')
  customApplications: appType
}[]

type securityPrincipalGroupsType = {
  @description('Required. The security principal ID to grant RBAC role to access AVD application group.')
  securityPrincipalName: string?
  @description('Required. The security principal ID to grant RBAC role to access AVD application group.')
  securityPrincipalId: string?
}[]?

// Published to the Azure Container Registry
