@description('The name the SQL server.')
param sqlServerName string

@description('The virtual network subnet ID.')
param virtualNetworkSubnetId string

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

resource network_rules 'Microsoft.Sql/servers/virtualNetworkRules@2023-05-01-preview' = {
  name: '${sqlServerName}_networkrule'
  parent: sqlServer
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId: virtualNetworkSubnetId
  }
}
