
using 'main.bicep'

param accountName = '${take('csmdb${uniqueString(database.name)}', 15)}'
param database = {
  name: 'testdb'
}
param containers = [
  {
    name: 'testcontainer'
    partitionKey: {
      kind: 'Hash'
      paths: [
        '/id'
      ]
    }
  }
  {
    name: 'leases'
    partitionKey: {
      kind: 'Hash'
      paths: [
        '/id'
      ]
    }
  }
  {
    name: 'deadletter'
    partitionKey: {
      kind: 'Hash'
      paths: [
        '/id'
      ]
    }
  }
]
