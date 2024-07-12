import { Container, RoleAssignments } from 'types/cosmosdb.bicep'

@description('Azure Cosmos DB account name, max length 44 characters')
param accountName string

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the database')
param databaseName string

@description('Lists of containers')
param containers Container[]

@description('Role assignments scoped to the account')
param roleAssignments RoleAssignments[] = []

// Adjust for production workloads
var backupPolicy = {
  type: 'Periodic'
  periodicModeProperties: {
    backupIntervalInMinutes: 1440
    backupRetentionIntervalInHours: 48
    backupStorageRedundancy: 'Local'
  }
}

var consistencyPolicy = {
  defaultConsistencyLevel: 'Session'
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: toLower(accountName)
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    disableKeyBasedMetadataWriteAccess: false
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    backupPolicy: backupPolicy
    consistencyPolicy: consistencyPolicy
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 1000
      }
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = [
  for container in containers: {
    parent: database
    name: container.name
    properties: {
      resource: {
        id: container.name
        partitionKey: container.partitionKey
        indexingPolicy: {
          indexingMode: 'consistent'
          includedPaths: [
            {
              path: '/*'
            }
          ]
          excludedPaths: [
            {
              path: '/_etag/?'
            }
          ]
          compositeIndexes: contains(container, 'compositeIndexes') ? container.compositeIndexes : []
        }
        uniqueKeyPolicy: {
          uniqueKeys: []
        }
      }
      options: {
        autoscaleSettings: {
          maxThroughput: 1000
        }
      }
    }
  }
]

resource role_assignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(account.name, assignment.principalId, assignment.roleDefinitionId)
    scope: account
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalId: assignment.principalId
      principalType: assignment.principalType
    }
  }
]

output accountName string = account.name
output databaseName string = database.name
output resourceGroupName string = resourceGroup().name
output resourceId string = database.id
