import { RoleAssignment } from '../types/rbac.bicep'
import { FileService, BlobService, QueueService, TableService } from '../types/storage-account.bicep'

@description('Provision a storage account name')
param name string

@description('Provide a location for the storage acocunt.')
param location string = resourceGroup().location

@description('Provide a sku for the storage account.')
param sku 'Standard_LRS' = 'Standard_LRS'

@description('Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is null, which is equivalent to true.')
param allowSharedKeyAccess bool?

@description('Allow or disallow public network access to Storage Account. Value is optional but if passed in, must be "Enabled" or "Disabled".')
param publicNetworkAccess 'Enabled' | 'Disabled' = 'Enabled'

@description('Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property..')
param allowBlobPublicAccess bool = true

@description('Provide the file services for the storage account.')
param fileServices FileService?

@description('Provide the blob services for the storage account.')
param blobServices BlobService?

@description('Provide the table services for the storage account.')
param tableServices TableService?

@description('Provide the queue services for the storage account.')
param queueServices QueueService?

@description('Provide role assignments scoped to the storage account.')
param roleAssignments RoleAssignment[] = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  sku: { name: sku }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: allowSharedKeyAccess
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
  }

  resource _fileServices 'fileServices@2023-05-01' = if (fileServices != null) {
    name: 'default'
    properties: {}
  }

  resource _blobServices 'blobServices@2023-05-01' = if (blobServices != null) {
    name: 'default'
    properties: {}
  }

  resource _queueServices 'queueServices@2023-05-01' = if (queueServices != null) {
    name: 'default'
    properties: {}

    resource queues 'queues@2023-05-01' = [
      for queue in queueServices.?queues ?? []: {
        name: queue.name
      }
    ]
  }

  resource _tableServices 'tableServices' = if (tableServices != null) {
    name: 'default'
    properties: {}
  }
}
resource storageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(storageAccount.id, assignment.principalId, assignment.roleDefinitionId)
    scope: storageAccount
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalId: assignment.principalId
      principalType: assignment.principalType
    }
  }
]

output blobPrimaryEndpoints string = storageAccount.properties.primaryEndpoints.blob
output tablePrimaryEndpoints string = storageAccount.properties.primaryEndpoints.table
output queuePrimaryEndpoints string = storageAccount.properties.primaryEndpoints.queue

output resourceId string = storageAccount.id
output name string = storageAccount.name
