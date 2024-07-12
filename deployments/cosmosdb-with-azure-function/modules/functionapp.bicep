@description('Azure Cosmos DB account name, max length 44 characters')
param cosmosDbAccountName string

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: toLower(cosmosDbAccountName)
}

module functionApp '../../../templates/compute/function-apps/dotnet/windows-standard/functionapp.bicep' = {
  name: 'moviesfunctionapp'
  params: {
    functionAppName: 'moviesapp${take(uniqueString(resourceGroup().id, location), 6)}'
    location: location
    appSettings: [
      {
        name: 'CosmosDbConnectionSetting'
        value: 'AccountEndpoint=https://${account.name}.documents.azure.com:443/;AccountKey=${account.listKeys().primaryMasterKey};'
      }
    ]
  }
}
