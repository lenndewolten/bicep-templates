using 'private-endpoints.bicep'

param sqlServerName = 'testlennartsqlserver'
param databaseName = 'testlennartdb'
param sqlAdministratorLogin = 'testlennart'
param sqlAdministratorLoginPassword = 'Mysecurepassword123!'

param vnetName = 'testlennartvnet'
param privateEndpointName = 'testlennartprivateendpoint'

param vmAdminUsername = 'testlennart'
param vmAdminPassword = 'Mysecurepassword123!'
