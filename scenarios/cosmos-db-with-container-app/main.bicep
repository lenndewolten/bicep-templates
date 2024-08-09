import { Database, Container, BackupPolicy, Location, ConsistencyPolicy } from '../../types/cosmosdb.bicep'

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('Azure Cosmos DB account name, max length 44 characters')
param accountName string

@description('The settings for the database')
param database Database

@description('Lists of containers')
param containers Container[]

module cosmos '../../shared/cosmosdb.bicep' = {
  name: 'cosmos-deployment'
  params: {
    location: location
    accountName: accountName
    database: database
    containers: containers
  }
}

output cosmosEndpoint string = cosmos.outputs.endpoint
