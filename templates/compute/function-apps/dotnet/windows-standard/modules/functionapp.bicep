import { AppSettings } from 'types.bicep'

@description('The name of the function app that you wish to create.')
param functionAppName string

@description('Location for the function app.')
param location string = resourceGroup().location

@description('The name of the App Service plan for the function app.')
param serverFarmName string

@description('The name for the storage account.')
param storageAccountName string

@description('The name of the application insights instance.')
param applicationInsightsName string

@description('App settings for the function app.')
param appSettings AppSettings[] = []

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

var defaultAppSettings = [
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
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
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsights.properties.ConnectionString
  }
  {
    name: 'AzureWebJobsStorage'
    value: storageAccountConnectionString
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: storageAccountConnectionString
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: 'tothemoonandback33b598'
  }
]

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appService 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: serverFarmName
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appService.id
    siteConfig: {
      numberOfWorkers: 1
      alwaysOn: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: concat(defaultAppSettings, appSettings)
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      use32BitWorkerProcess: false
      cors: {
        allowedOrigins: ['*']
      }
    }
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
  }
}
