
using 'main.bicep'

param sqlServerName = '${take('prvtsql${uniqueString(vnetRsourceGroup)}', 15)}'
param sqlAdministratorLogin = 'testsqladmin' // This is a placeholder value and should be tokenized with a secure value
param sqlAdministratorLoginPassword = 'Th3B3stPa$$word!' // This is a placeholder value and should be tokenized with a secure value

param databases = [
  {
    name: 'testlennartdb'
    sku: {
      name: 'Basic'
      tier: 'Basic'
      capacity: 5
    }
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
]

param vnetRsourceGroup = 'my-private-network'
param vnetName = 'private-network-test'
param subnetName = 'default'
