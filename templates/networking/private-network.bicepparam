using 'private-network.bicep'

param vnetName = 'private-network-test'
param privateLinkSubResources = [
  'blob', 'queue', 'table', 'sqlServer'
]
