
using 'main.bicep'

param storageAccountName = '${take('prvtstrg${uniqueString(vnetRsourceGroup)}', 15)}'
param vnetRsourceGroup = 'my-private-network'
param vnetName = 'private-network-test'
param subnetName = 'default'
