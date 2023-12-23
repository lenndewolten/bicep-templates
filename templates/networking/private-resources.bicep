@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the resource group.')
param vnetRsourceGroup string

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string

@description('The name the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL logical server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The name the SQL database.')
param databaseName string

@description('The name the storageAccount.')
param storageAccountName string

@description()
@allowed([
  'table'
  'blob'
  'queue'
])
param tableServices array = []

@description('The name prefix of the VM.')
param vmNamePrefix string = 'networktest'

@description('Username for the Virtual Machine.')
param vmAdminUsername string

@description('Password for the Virtual Machine. The password must be at least 12 characters long and have lower case, upper characters, digit and a special character (Regex match)')
@secure()
param vmAdminPassword string

var vmName = take('${vmNamePrefix}${uniqueString(resourceGroup().id)}', 15)
var sqlPrivateEndpointName = '${sqlServerName}-private-endpoint'
var sqlPvtEndpointDnsGroupName = '${sqlPrivateEndpointName}/dnsgroup'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'

    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRsourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: vnet
  name: subnetName
}

module sqlPrivateEndpoint 'modules/private-endpoint.bicep' = {
  name: 'sql-private-endpoint'

}

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: sqlPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: sqlPrivateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: sqlPrivateDnsZoneName
  scope: resourceGroup(vnetRsourceGroup)
}

resource sqlPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: sqlPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZone.id
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource pvtEndpointsStorageAccount =

module test_virtual_machine 'modules/test-vm.bicep' = {
  name: 'virtual-machine-${vmName}'
  params: {
    name: vmName
    location: location
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetId: subnet.id
    tags: {
      environment: 'test'
      name: 'networktest'
    }
  }
}
