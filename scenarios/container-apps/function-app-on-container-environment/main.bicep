@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide the registry for the function app.')
param registry Registry

@description('Provide a prefix for the resources.')
@minLength(5)
param resourceNamePrefix string

@description('Provide a postfix for the deployment.')
param deployementPostfix string = newGuid()

var envResourceNamePrefix = toLower(resourceNamePrefix)
var envDeploymentPostfix = take(uniqueString(toLower(deployementPostfix)), 6)

module storageAccount '../../../shared/storage-account.bicep' = {
  name: 'storageaccount-${envDeploymentPostfix}'
  params: {
    name: '${envResourceNamePrefix}strg'
    sku: 'Standard_LRS'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${envResourceNamePrefix}-la'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${envResourceNamePrefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registry.name
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
}

module functionApp './modules/functionapp.bicep' = {
  name: 'function-app-${envDeploymentPostfix}'
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppEnvRG: containerAppEnvRG
    functionAppName: '${envResourceNamePrefix}-funcapp'
    storageAccountName: storageAccount.outputs.name
    appInsightsName: appInsights.name
    registry: registry
    identityName: '${envResourceNamePrefix}-identity'
    linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/azurefunctions:quickstart-isolated8-v1.0.0'
  }
}

output fqdn string = functionApp.outputs.fqdn

type Registry = {
  name: string
  resourceGroup: string?
}
