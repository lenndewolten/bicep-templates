@minLength(5)
@maxLength(50)
@description('Provide a name of your Container App Environment.')
param name string

@description('Provide a location for the Container App Environment.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a resource id for the identity.')
param identityId string

@description('Provide a name of your Azure Container Registry')
param acrName string
@description('Provide the resource group for the container environment.')
param acrRG string = resourceGroup().name

@description('Provide the ingress for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#ingress')
param ingress object

@description('Provide an array of containers for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#container')
param containers array

@description('Provide the scale for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale')
param scale object

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
  scope: resourceGroup(acrRG)
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    configuration: {
      ingress: ingress
      registries: [
        {
          identity: identityId
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
