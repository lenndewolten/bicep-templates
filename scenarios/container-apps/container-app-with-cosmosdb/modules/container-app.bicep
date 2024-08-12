import { Container, Ingress, Scale } from '../../../../types/container-app.bicep'

@description('Location for the container app.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide an array of containers for the container app')
param containers Container[]

@description('Provide the ingress for the container app')
param ingress Ingress

@description('Provide the scale for the container app.')
param scale Scale

@description('Azure Cosmos DB account name, max length 44 characters')
param cosmosAccountName string

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: cosmosAccountName
}

var secrets = [
  { name: 'COSMOS__ACCOUNTKEY', value: account.listKeys().primaryMasterKey }
]

var containerEnv = concat([
  {
    name: 'COSMOS__ACCOUNTENDPOINT'
    value: account.properties.documentEndpoint
  }
])

module containerApp '../../../../shared/container-app.bicep' = {
  name: 'container-app-deployment'
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppEnvRG: containerAppEnvRG
    name: containerAppName
    ingress: ingress
    secrets: secrets
    containers: [
      for container in containers: union(container, {
        env: concat(containerEnv, container.?env ?? [])
      })
    ]
    scale: scale
    location: location
  }
}

output containerEnv array = containerEnv
