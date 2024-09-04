// Azure Bicep deployment file for deploying common components for this Solution Accelerator
targetScope = 'subscription'

@description('Provide the name of the Resource Group for shared components.')
param sharedComponentsRGName string = 'automation-library-rg'

@description('Provide location for resources.')
param location string = 'westeurope'

param tags object

param moduleRegistryName string = 'autlibbicepreg'

param staticWebAppName string = 'wssmax001'

param time string = utcNow()

// Create a resource group
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: sharedComponentsRGName
  location: location
  tags: tags
}

// Create a Container Registry
module moduleRegistry 'br/public:avm/res/container-registry/registry:0.3.0' = {
  scope: rg
  name: 'Bicep-Registry-Deploy-${time}'
  params: {
    name: moduleRegistryName
    acrSku: 'Basic'
  }
}

// Azure Static Web App
module staticSite 'br/public:avm/res/web/static-site:0.3.1' = {
  name: 'Static-Webapp-Deploy-${time}'
  scope: rg
  params: {
    name: staticWebAppName
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
    location: location
    sku: 'Standard'
    stagingEnvironmentPolicy: 'Disabled'
  }
}



