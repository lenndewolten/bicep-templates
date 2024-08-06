import { Container, Ingress } from 'types/types.bicep'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide the ingress for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#ingress')
param ingress Ingress

@description('Provide an array of containers for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#container')
param containers Container[]

@description('Provide the scale for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale')
param scale object

@description('Provide a name of your Azure Container Registry')
param acrName string
@description('Provide the resource group for the container environment.')
param acrRG string = resourceGroup().name

@description('Provide a name of the managed identity.')
param identityName string = '${containerAppName}-identity'

@description('Provide a name for the storage account if applicable.')
param storageAccountName string = ''

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module containerApp_identity_acrPullRole 'modules/role-assignments.bicep' = {
  name: 'container-app-acr-access-${containerAppName}'
  scope: resourceGroup(acrRG)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRole
  }
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

module containerApp 'modules/container-app.bicep' = {
  name: 'container-app-${containerAppName}'
  dependsOn: [
    containerApp_identity_acrPullRole
  ]
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppEnvRG: containerAppEnvRG
    acrName: acrName
    acrRG: acrRG
    identityId: identity.id
    name: containerAppName
    ingress: ingress
    containers: [
      for container in containers: union(container, {
        env: contains(container, 'env') ? concat(containerEnv, container.env) : containerEnv
      })
    ]
    scale: scale
    location: location
  }
}

var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageQueueDataContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageTableDataContributorRole = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'

module storageaccount 'modules/storageaccount.bicep' = if (storageAccountName != '') {
  name: 'storageaccount-${containerAppName}'
  params: {
    name: storageAccountName
    location: location
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
