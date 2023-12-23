using 'private-resources.bicep'

param sqlServerName = 'testlennartsqlserver'
param databaseName = 'testlennartdb'
param sqlAdministratorLogin = 'testlennart'
param sqlAdministratorLoginPassword = 'Mysecurepassword123!'

param vnetRsourceGroup = 'private-network'
param vnetName = 'private-network-test'
param subnetName = 'default'

param vmAdminUsername = 'testlennart'
param vmAdminPassword = 'Mysecurepassword123!'
