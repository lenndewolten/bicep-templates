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

module sql_privateEndpoint 'modules/private-endpoint.bicep' = {
  name: 'sql-private-endpoint'
  params: {
    location: location
    subnetId: subnet.id
    privateEndpointName: 'sql-private-endpoint'
    vnetRsourceGroup: vnetRsourceGroup
    privateLinkSubResource: 'sqlServer'
    privateLinkServiceId: sqlServer.id
  }
}
