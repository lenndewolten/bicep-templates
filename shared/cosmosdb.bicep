import { Database, Container, BackupPolicy, Location, ConsistencyPolicy } from '../types/cosmosdb.bicep'
import { RoleAssignment } from '../types/rbac.bicep'

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('Azure Cosmos DB account name, max length 44 characters')
@maxLength(44)
param accountName string

@description('The settings for the database')
param database Database

@description('Lists of containers')
param containers Container[]

@description('Flag to indicate whether Free Tier is enabled.')
param enableFreeTier bool = true

@description('Enables automatic failover of the write region in the rare event that the region is unavailable due to an outage. Automatic failover will result in a new write region for the account and is chosen based on the failover priorities configured for the account.')
param enableAutomaticFailover bool = false

param backupPolicy BackupPolicy = {
  type: 'Periodic'
  periodicModeProperties: {
    backupIntervalInMinutes: 1440
    backupRetentionIntervalInHours: 48
    backupStorageRedundancy: 'Local'
  }
}

param locations Location[] = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

param consistencyPolicy ConsistencyPolicy = {
  defaultConsistencyLevel: 'Session'
}

@description('Role assignments scoped to the account')
param roleAssignments RoleAssignment[] = []

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: toLower(accountName)
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    enableFreeTier: enableFreeTier
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: enableAutomaticFailover
    disableKeyBasedMetadataWriteAccess: false
    locations: locations
    backupPolicy: union(
      { type: backupPolicy.type },
      backupPolicy.type == 'Periodic'
        ? { periodicModeProperties: backupPolicy.periodicModeProperties }
        : { continuousModeProperties: backupPolicy.continuousModeProperties }
    )
    consistencyPolicy: consistencyPolicy
  }
}

resource _database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: account
  name: database.name
  properties: {
    resource: {
      id: database.name
    }
    options: {
      autoscaleSettings: database.?autoscaleSettings ?? {
        maxThroughput: 1000
      }
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = [
  for container in containers: {
    parent: _database
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
          compositeIndexes: container.?compositeIndexes ?? []
        }
        uniqueKeyPolicy: container.?uniqueKeyPolicy ?? {
          uniqueKeys: []
        }
      }
      options: {
        autoscaleSettings: container.?autoscaleSettings ?? {
          maxThroughput: 1000
        }
      }
    }
  }
]

resource accountRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
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

output endpoint string = account.properties.documentEndpoint
