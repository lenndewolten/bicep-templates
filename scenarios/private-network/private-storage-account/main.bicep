@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the storage account.')
param storageAccountName string

@description('The name of the resource group.')
param vnetRsourceGroup string

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string

module storageAccount '../../../shared/storage-account.bicep' = {
  name: storageAccountName
  params: {
    name: storageAccountName
    location: location
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    tableServices: {}
    blobServices: {
      restorePolicy: {
        enabled: false
      }
      deleteRetentionPolicy: {
        enabled: false
      }
      containerDeleteRetentionPolicy: {
        enabled: false
      }
      changeFeed: {
        enabled: false
      }
      isVersioningEnabled: false
    }
    queueServices: {}
  }
}

module private_endpoints '../../../shared/private-endpoint.bicep' = [
  for subResource in ['table', 'queue', 'blob']: {
    name: '${subResource}-pvt'
    params: {
      location: location
      vnetRsourceGroup: vnetRsourceGroup
      vnetName: vnetName
      subnetName: subnetName
      privateEndpointName: '${subResource}-${storageAccountName}'
      privateLinkServiceResourceId: storageAccount.outputs.resourceId
      privateLinkSubResource: subResource
      customNetworkInterfaceName: '${storageAccountName}-${subResource}-pvt-nic'
    }
  }
]

output storageAccountResourceId string = storageAccount.outputs.resourceId
