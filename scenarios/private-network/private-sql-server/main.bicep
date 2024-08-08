import { Database } from '../../../types/sql-server.bicep'

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

@description('The SQL databases to attach to the server.')
param databases Database[]

module sql '../../../shared/sql-server.bicep' = {
  name: 'sql-deployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    publicNetworkAccess: 'Disabled'
    databases: databases
  }
}

module sql_privateEndpoint '../../../shared/private-endpoint.bicep' = {
  name: 'sql-private-endpoint'
  params: {
    location: location
    vnetRsourceGroup: vnetRsourceGroup
    vnetName: vnetName
    subnetName: subnetName
    privateEndpointName: 'sql-private-endpoint'
    privateLinkSubResource: 'sqlServer'
    privateLinkServiceResourceId: sql.outputs.sqlServerResourceId
  }
}

output sqlServerResourceId string = sql.outputs.sqlServerResourceId
output sqlServerFqdn string = sql.outputs.sqlServerFqdn
