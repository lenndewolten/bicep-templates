using 'private-sql-server.bicep'

param sqlServerName = 'testlennartsqlserver'
param databaseName = 'testlennartdb'
param sqlAdministratorLogin = 'testlennart'
param sqlAdministratorLoginPassword = ''

param vnetRsourceGroup = 'private-network'
param vnetName = 'private-network-test'
param subnetName = 'default'
