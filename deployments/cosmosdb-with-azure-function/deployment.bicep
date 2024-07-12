@description('Azure Cosmos DB account name, max length 44 characters')
param accountName string

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the database')
param databaseName string = 'moviesDB'

module functionApp './modules/functionapp.bicep' = {
  name: 'moviesfunctionappdeployment'
  params: {
    location: location
    cosmosDbAccountName: cosmosDB.outputs.accountName
  }
}

module cosmosDB '../../templates/storage/cosmosdb/cosmosdb.bicep' = {
  name: accountName
  params: {
    location: location
    accountName: accountName
    databaseName: databaseName
    containers: [
      {
        name: 'moviesByYear'
        partitionKey: {
          kind: 'Hash'
          paths: [
            '/year'
          ]
        }
      }
      {
        name: 'moviesByGenre'
        partitionKey: {
          kind: 'Hash'
          paths: [
            '/genre'
          ]
        }
      }
    ]
  }
}
