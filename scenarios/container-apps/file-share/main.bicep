import { Container, Ingress } from '../../../types/container-app.bicep'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('The private registries to be used by the container app')
param registries Registry[] = []

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide a name of the managed identity.')
param identityName string = '${containerAppName}-identity'

@description('Provide a name for the storage account if applicable.')
param storageAccountName string

@description('Provide an array of containers for the container app')
param containers Container[]

@description('Provide the ingress for the container app')
param ingress Ingress

@description('Provide the scale for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale')
param scale object

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module storageAccount '../../../shared/storage-account.bicep' = {
  name: 'storageaccount-${containerAppName}'
  scope: resourceGroup(containerAppEnvRG)
  params: {
    name: storageAccountName
    sku: 'Standard_LRS'
    fileServices: {}
  }
}

module fileShareLink 'modules/fileshare.bicep' = {
  name: 'fileshare-link'
  scope: resourceGroup(containerAppEnvRG)
  params: {
    name: 'myfileshare'
    containerAppEnvName: containerAppEnvName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    storageAccount
  ]
}

module _registries './modules/registries.bicep' = {
  name: 'registries'
  params: {
    registries: map(registries, registry => {
      name: registry.name
      identity: {
        resourceId: identity.id
        principalId: identity.properties.principalId
      }
      resourceGroup: registry.resourceGroup
    })
  }
}

module containerApp '../../../shared/container-app.bicep' = {
  name: 'container-app-${containerAppName}'
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppEnvRG: containerAppEnvRG
    registries: _registries.outputs.registries
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${identity.id}': {}
      }
    }
    name: containerAppName
    ingress: ingress
    containers: containers
    scale: scale
    location: location
    volumes: [
      {
        name: 'myfileshare'
        storageName: fileShareLink.outputs.filesShareLinkName
        storageType: 'AzureFile'
      }
    ]
  }
}

output fqdn string = containerApp.outputs.fqdn

type Registry = {
  name: string
  resourceGroup: string?
}
