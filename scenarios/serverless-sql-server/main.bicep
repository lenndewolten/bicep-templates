import { Database } from '../../types/sql-server.bicep'

@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string = 'default'

@description('The name the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL logical server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The SQL databases to attach to the server.')
param databases Database[]

var vnetAddressPrefix = '10.0.0.0/16'

var _subnet = {
  name: subnetName
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
        name: _subnet.name
        properties: {
          addressPrefix: _subnet.addressPrefix
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

module sql '../../shared/sql-server.bicep' = {
  name: 'sql-deployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    databases: databases
  }
}

module network_rules 'modules/sql-network-rules.bicep' = {
  name: 'network-rules'
  params: {
    sqlServerName: sql.outputs.sqlServerName
    virtualNetworkSubnetId: vnet.properties.subnets[0].id
  }
}

output sqlServerResourceId string = sql.outputs.sqlServerResourceId
output sqlServerFqdn string = sql.outputs.sqlServerFqdn
