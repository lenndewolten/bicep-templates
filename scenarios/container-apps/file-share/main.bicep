import { Container, Ingress } from '../../../types/containerapps.bicep'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide a name of your Azure Container Registry')
param acrName string
@description('Provide the resource group for the container environment.')
param acrRG string

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

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module containerApp_identity_acrPullRole '../../../shared/role-assignments.bicep' = {
  name: 'container-app-acr-access-${containerAppName}'
  scope: resourceGroup(acrRG)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRole
  }
}

module storageAccount '../../../shared/storageaccount.bicep' = {
  name: 'storageaccount-${containerAppName}'
  scope: resourceGroup(acrRG)
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

module containerApp '../../../shared/container-app.bicep' = {
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
