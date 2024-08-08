
using 'main.bicep'

param sqlServerName = '${take('prvtsql${uniqueString(vnetName)}', 15)}'
param sqlAdministratorLogin = 'testsqladmin' // This is a placeholder value and should be tokenized with a secure value
param sqlAdministratorLoginPassword = 'Th3B3stPa$$word!' // This is a placeholder value and should be tokenized with a secure value

param databases = [
  {
    name: 'testlennartdb'
    sku: {
      name: 'GP_S_Gen5_1'
      tier: 'GeneralPurpose'
    }
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    sampleName: 'AdventureWorksLT'
    autoPauseDelay: 60
    useFreeLimit: true
    freeLimitExhaustionBehavior: 'AutoPause'
  }
]

param vnetName = 'sql-network'
