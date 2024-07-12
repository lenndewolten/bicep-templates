@description('The name of the function app that you wish to create.')
param functionAppName string

@description('The name for the storage account.')
param storageAccountName string = '${functionAppName}storage'

@description('Indicates the type of storage account.')
@allowed([
  'Storage'
  'StorageV2'
])
param storageAccountKind string = 'Storage'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the log analytics workspace.')
param logAnalyticsWorkspaceName string = '${functionAppName}-workspace'

@description('The name of the application insights instance.')
param applicationInsightsName string = '${functionAppName}-insights'

@description('App settings for the function app.')
param appSettings AppSettings[] = []

var defaultAppSettings = [
  {
    name: 'AzureWebJobsFeatureFlags'
    value: 'EnableWorkerIndexing'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'WEBSITE_NODE_DEFAULT_VERSION'
    value: '~14'
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsights.properties.ConnectionString
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
  {
    name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
    value: '1'
  }
  {
    name: 'AzureWebJobsStorage__accountName'
    value: storageAccount.name
  }
]

var storageBlobDataOwnerRole = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: storageAccountKind
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    allowSharedKeyAccess: false
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource appContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'appcontainer'
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'serverless'
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: concat(defaultAppSettings, appSettings)
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
  }
}

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountName, functionAppName, storageBlobDataOwnerRole)
  scope: storageAccount
  properties: {
    roleDefinitionId: storageBlobDataOwnerRole
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output appContainerName string = appContainer.name
output principalId string = functionApp.identity.principalId

type AppSettings = {
  name: string
  value: string
}
