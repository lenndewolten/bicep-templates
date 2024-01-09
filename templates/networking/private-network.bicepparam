using 'private-network.bicep'

param vnetName = 'private-network-test'
param privateLinkSubResources = [
  'blob', 'queue', 'table', 'sqlServer'
]

param vmAdminUsername = 'testlennart'
param vmAdminPassword = 'Mysecurepassword123!'
