using 'cosmosdb.bicep'

param accountName = 'tothemoonandback'
param databaseName = 'moviesDB'
param containers = [
  {
    name: 'movies'
    partitionKey: {
      kind: 'Hash'
      paths: [
        '/id'
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
