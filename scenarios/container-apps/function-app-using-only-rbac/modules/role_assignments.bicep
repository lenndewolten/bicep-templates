@description('Provide the principal ID of the identity')
param principalId string

@description('Provide the ACR registry details')
param registry Registry

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var storageAccountContributor = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
var storageBlobDataOwnerRole = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var storageQueueContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageTableDataContributor = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'

module functionApp_acrPullRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-acr-access'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: acrPullRole
  }
}

module functionApp_storageAccountContributor '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-storage-contributor'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageAccountContributor
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

module functionApp_storageQueueContributorRole '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-queue-contributor'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageQueueContributorRole
  }
}

module functionApp_storageTableDataContributor '../../../../shared/role-assignments.bicep' = {
  name: 'funcapp-table-contributor'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: principalId
    roleDefinitionId: storageTableDataContributor
  }
}

type Registry = {
  name: string
  resourceGroup: string?
}
