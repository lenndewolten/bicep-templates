
using 'main.bicep'

param vnetName = 'private-network-test'
param privateLinkSubResources = [
  'blob'
  'queue'
  'table'
  'sqlServer'
]

param vmAdminUsername = 'jumphostuser' // Optional: Leave blank to skip jumpbox deployment. This is a placeholder value and should be tokenized with a secure value
param vmAdminPassword = 'Th3B3stPa$$word!' // Optional: Leave blank to skip jumpbox deployment. This is a placeholder value and should be tokenized with a secure value 
