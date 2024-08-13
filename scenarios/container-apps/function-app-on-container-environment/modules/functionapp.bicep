@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string

@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide the name for the function app.')
param functionAppName string

param storageAccountName string
param appInsightsName string
param identityName string
param registry Registry

param linuxFxVersion string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registry.name
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
}

resource functionapp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  dependsOn: [
    containerApp_identity_acrPullRole
  ]
  kind: 'functionapp,linux,container,azurecontainerapps'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/azurefunctions:quickstart-isolated8-v1.0.0'
      // linuxFxVersion: 'DOCKER|lenndewoltentestacr.azurecr.io/azurefunctions:quickstart-isolated8-v1.0.0'
      linuxFxVersion: linuxFxVersion
      acrUserManagedIdentityID: identity.id
      acrUseManagedIdentityCreds: true
      minimumElasticInstanceCount: 1
      functionAppScaleLimit: 5
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: acr.properties.loginServer
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

module containerApp_identity_acrPullRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-acr-access'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRole
  }
}

output fqdn string = functionapp.properties.defaultHostName

type Registry = {
  name: string
  resourceGroup: string?
}
