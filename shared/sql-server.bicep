import { Database } from '../types/sql-server.bicep'

@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL logical server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The public network access setting for the SQL logical server.')
param publicNetworkAccess 'Enabled' | 'Disabled' = 'Enabled'

@description('The SQL databases to attach to the server.')
param databases Database[]

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: publicNetworkAccess
  }
}

resource _databases 'Microsoft.Sql/servers/databases@2023-05-01-preview' = [
  for database in databases: {
    parent: sqlServer
    name: database.name
    location: location
    sku: database.sku
    properties: {
      collation: database.?collation ?? null
      maxSizeBytes: database.?maxSizeBytes ?? null
      sampleName: database.?sampleName ?? null
      autoPauseDelay: database.?autoPauseDelay ?? -1
      useFreeLimit: database.?useFreeLimit ?? false
      freeLimitExhaustionBehavior: database.?freeLimitExhaustionBehavior ?? null
    }
  }
]

output sqlServerResourceId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
