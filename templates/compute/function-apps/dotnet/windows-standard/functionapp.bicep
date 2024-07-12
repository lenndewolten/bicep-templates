import { AppSettings } from 'modules/types.bicep'

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

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: storageAccountKind
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: false
    allowSharedKeyAccess: true
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
    reserved: false
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

module functionApp 'modules/functionapp.bicep' = {
  name: functionAppName
  params: {
    functionAppName: functionAppName
    location: location
    serverFarmName: hostingPlan.name
    applicationInsightsName: applicationInsights.name
    storageAccountName: storageAccount.name
    appSettings: appSettings
  }
}

output functionAppName string = functionApp.name
