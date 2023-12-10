@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide the ingress for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#ingress')
param ingress object

@description('Provide an array of containers for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#container')
param containers array

@description('Provide the scale for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale')
param scale object

@description('Provide a name of your Azure Container Registry')
param acrName string
@description('Provide the resource group for the container environment.')
param acrRG string = resourceGroup().name

@description('Provide a name of the managed identity')
param identityName string = '${containerAppName}-identity'

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
  scope: resourceGroup(acrRG)
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module containerApp_identity_acrPullRole '../../modules/authorization/role-assignments.bicep' = {
  name: 'container-app-acr-access'
  scope: resourceGroup(acrRG)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRole
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  dependsOn: [
    containerApp_identity_acrPullRole
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    configuration: {
      ingress: ingress
      registries: [
        {
          identity: identity.id
          server: acr.properties.loginServer
        }
      ]
    }
    environmentId: containerAppEnv.id
    template: {
      containers: containers
      scale: scale
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
