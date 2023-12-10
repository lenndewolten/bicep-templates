@description('Provision a storage account name')
param name string

@description('Provide a location for the storage acocunt.')
param location string = resourceGroup().location

@description('Provide a sku for the storage account.')
param sku string = 'Standard_LRS'

@description('Provide role assignments scoped to the storage account.')
param roleAssignments array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  sku: { name: sku }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false
  }
}

resource storageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(storageAccount.id, assignment.principalId, assignment.roleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]
