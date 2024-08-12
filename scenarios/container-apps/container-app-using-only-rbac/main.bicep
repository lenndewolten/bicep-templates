import { Container, Ingress, Scale } from '../../../types/container-app.bicep'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide the ingress for the container app')
param ingress Ingress

@description('Provide an array of containers for the container app')
param containers Container[]

@description('Provide the scale for the container app.')
param scale Scale

@description('The private registries to be used by the container app')
param registries Registry[] = []

@description('Provide a name of the managed identity.')
param identityName string = '${containerAppName}-identity'

@description('Provide a name for the storage account if applicable.')
param storageAccountName string = ''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

var defaultContainerEnv = [
  {
    name: 'AZURE_CLIENT_ID'
    value: identity.properties.clientId
  }
]

var storageAccountContainerEnv = storageAccountName != ''
  ? [
      {
        name: 'STORAGE_ACCOUNT_TABLE_URI'
        value: storageaccount.outputs.tablePrimaryEndpoints
      }
      {
        name: 'STORAGE_ACCOUNT_BLOB_URI'
        value: storageaccount.outputs.blobPrimaryEndpoints
      }
      {
        name: 'STORAGE_ACCOUNT_QUEUE_URI'
        value: storageaccount.outputs.queuePrimaryEndpoints
      }
    ]
  : []

var containerEnv = concat(defaultContainerEnv, storageAccountName != '' ? storageAccountContainerEnv : [])

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
    containers: [
      for container in containers: union(container, {
        env: contains(container, 'env') ? concat(containerEnv, container.env!) : containerEnv
      })
    ]
    scale: scale
    location: location
  }
}

var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageQueueDataContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageTableDataContributorRole = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'

module storageaccount '../../../shared/storage-account.bicep' = if (storageAccountName != '') {
  name: 'storageaccount-${containerAppName}'
  params: {
    name: storageAccountName
    location: location
    tableServices: {}
    blobServices: {}
    queueServices: {}
    roleAssignments: [
      {
        roleDefinitionId: storageBlobDataContributorRole
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionId: storageQueueDataContributorRole
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionId: storageTableDataContributorRole
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

output fqdn string = containerApp.outputs.fqdn

type Registry = {
  name: string
  resourceGroup: string?
}
