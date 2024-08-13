@description('Provide the principal ID of the identity')
param principalId string

@description('Provide the ACR registry details')
param registry Registry

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var storageBlobDataOwnerRole = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var storageQueueDataReaderRole = '19e7f393-937e-4f77-808e-94535e297925'
var storageQueueProcessorRole = '8a0f0c08-91a1-4084-bc3d-661d67233fed'
var storageQueueContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageQueueSenderRole = 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'

module functionApp_acrPullRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-acr-access'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: acrPullRole
  }
}

module functionApp_storageBlobDataOwnerRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-blob-owner'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageBlobDataOwnerRole
  }
}

module functionApp_storageQueueDataReaderRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-queue-data-reader'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageQueueDataReaderRole
  }
}

module functionApp_storageQueueProcessorRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-queue-processor'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageQueueProcessorRole
  }
}

module functionApp_storageQueueContributorRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-queue-contributor'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageQueueContributorRole
  }
}

module functionApp_storageQueueSenderRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-queue-sender'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageQueueSenderRole
  }
}

type Registry = {
  name: string
  resourceGroup: string?
}
