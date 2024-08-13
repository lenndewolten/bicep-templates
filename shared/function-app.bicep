import { Kind, SiteConfig, StorageAccountProperties, ApplicationInsightsProperties } from '../types/function-app.bicep'
import { ManagedServiceIdentity } from '../types/rbac.bicep'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide the name for the function app.')
param functionAppName string

@description('Provide what kind of function app you want.')
param kind Kind

@description('Provide a identity for the function app.')
param identityName string?

@description('Provide the resource ID of the associated container app environment. Required if kind is "azurecontainerapps".')
param managedEnvironmentId string?

@description('Provide the resource ID of the associated App Service plan. Required if kind is not "azurecontainerapps".')
param serverFarmId string?

@description('Provide the config of the function app.')
param siteConfig SiteConfig

@description('Flag to indicate if the identity should be used only for the function app.')
param useIdentityOnly bool = false

@description('Provide the storage account.')
param storageAccount StorageAccountProperties

@description('Provide the application insights.')
param applicationInsights ApplicationInsightsProperties

resource _storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccount.name
  scope: resourceGroup(storageAccount.?resourceGroup ?? resourceGroup().name)
}

resource _appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsights.name
  scope: resourceGroup(applicationInsights.?resourceGroup ?? resourceGroup().name)
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (identityName != null && identityName != '') {
  name: identityName!
}

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${_storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${_storageAccount.listKeys().keys[0].value}'

var appSettings = useIdentityOnly
  ? [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: _appInsights.properties.ConnectionString
      }
      {
        name: 'AzureWebJobsStorage__credential'
        value: 'managedidentity'
      }
      {
        name: 'AzureWebJobsStorage__clientId'
        value: identity.properties.clientId
      }
      {
        name: 'AzureWebJobsStorage__accountName'
        value: storageAccount.name
      }
    ]
  : [
      {
        name: 'AzureWebJobsStorage'
        value: storageConnectionString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: _appInsights.properties.ConnectionString
      }
    ]

resource functionapp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: kind
  identity: identityName != null && identityName != ''
    ? {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${identity.id}': {}
        }
      }
    : { type: 'None' }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion: siteConfig.linuxFxVersion
      acrUserManagedIdentityID: siteConfig.?acrUserManagedIdentityID
      acrUseManagedIdentityCreds: siteConfig.?acrUseManagedIdentityCreds
      minimumElasticInstanceCount: siteConfig.?minimumElasticInstanceCount ?? 0
      functionAppScaleLimit: siteConfig.?functionAppScaleLimit ?? 5
      appSettings: concat(appSettings, siteConfig.?appSettings ?? [])
    }
  }
}

output fqdn string = functionapp.properties.defaultHostName
