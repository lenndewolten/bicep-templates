@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the vnet.')
param vnetName string

@description('The name the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL logical server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The name the SQL database.')
param databaseName string

@description('Whether or not the database uses free monthly limits. Allowed on one database in a subscription.')
param useFreeLimit bool = true

@description('Specifies the behavior when monthly free limits are exhausted for the free database.')
param freeLimitExhaustionBehavior FreeLimitExhaustionBehavior = 'AutoPause'

var vnetAddressPrefix = '10.0.0.0/16'

var _defaultSubnet = {
  name: 'default'
  addressPrefix: '10.0.0.0/24'
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: _defaultSubnet.name
        properties: {
          addressPrefix: _defaultSubnet.addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: ['*']
            }
          ]
        }
      }
    ]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource network_rules 'Microsoft.Sql/servers/virtualNetworkRules@2023-05-01-preview' = {
  name: '${sqlServerName}_networkrule'
  parent: sqlServer
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId: vnet.properties.subnets[0].id
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    sampleName: 'AdventureWorksLT'
    autoPauseDelay: 60
    useFreeLimit: useFreeLimit
    freeLimitExhaustionBehavior: freeLimitExhaustionBehavior
  }
}

type FreeLimitExhaustionBehavior = 'AutoPause' | 'BillOverUsage'
