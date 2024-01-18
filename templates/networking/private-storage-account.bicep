@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the resource group.')
param vnetRsourceGroup string

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string

var storageAccountName = take('lenny${uniqueString(resourceGroup().id)}', 15)

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRsourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: vnet
  name: subnetName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
      }
    }
  }

  resource tableServices 'tableServices' = {
    name: 'default'
    properties: {}
  }

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
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
  }

  resource queueServices 'queueServices' = {
    name: 'default'
    properties: {}
  }
}

module private_endpoints 'modules/private-endpoint.bicep' = [for subResource in [ 'table', 'queue', 'blob' ]: {
  name: '${subResource}-pvt'
  params: {
    location: location
    vnetRsourceGroup: vnetRsourceGroup
    subnetId: subnet.id
    privateEndpointName: '${subResource}-${storageAccountName}'
    privateLinkServiceId: storageAccount.id
    privateLinkSubResource: subResource
    customNetworkInterfaceName: '${storageAccountName}-${subResource}-pvt-nic'
  }
}]
