import { Database, Container as CosmosContainer, BackupPolicy, Location, ConsistencyPolicy } from '../../types/cosmosdb.bicep'
import { Container, Ingress } from '../../types/container-app.bicep'

@description('Cosmos DB settings')
param cosmosDbConfig CosmosDbConfig

@description('Container App settings')
param containerAppConfig ContainerAppConfig

module cosmos '../../shared/cosmosdb.bicep' = {
  name: 'cosmos-deployment'
  params: {
    location: cosmosDbConfig.?location
    accountName: cosmosDbConfig.accountName
    database: cosmosDbConfig.database
    containers: cosmosDbConfig.containers
  }
}

module containerApp './modules/container-app.bicep' = {
  name: '${containerAppConfig.name}-module'
  params: {
    containerAppEnvName: containerAppConfig.environment.name
    containerAppEnvRG: containerAppConfig.environment.resourceGroup
    containerAppName: containerAppConfig.name
    cosmosAccountName: cosmos.outputs.accountName
    ingress: containerAppConfig.ingress
    containers: containerAppConfig.containers
    scale: containerAppConfig.scale
    location: containerAppConfig.?location
  }
}

output cosmosEndpoint string = cosmos.outputs.endpoint

type CosmosDbConfig = {
  accountName: string
  database: Database
  containers: CosmosContainer[]
  location: string?
}

type ContainerAppConfig = {
  environment: {
    name: string
    resourceGroup: string?
  }
  name: string
  location: string?
  ingress: Ingress
  containers: Container[]
  @description('Provide the scale for the container app: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale')
  scale: object
}
