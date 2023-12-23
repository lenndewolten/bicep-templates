@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string = 'default'

@description('The private link subresources for automatic CNAME resolution to be linked to the vnet. See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#commercial')
@allowed([
  'blob'
  'file'
  'queue'
  'table'
  'sqlServer'
])
param privateLinkSubResources array = []

var vnetAddressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'

var mapping = {
  blob: '.blob.${environment().suffixes.storage}'
  file: '.file.${environment().suffixes.storage}'
  table: '.table.${environment().suffixes.storage}'
  queue: '.queue.${environment().suffixes.storage}'
  sqlServer: environment().suffixes.sqlServerHostname
}
var dnsZonesNames = [for resource in privateLinkSubResources: 'privatelink${mapping[resource]}']

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      { name: subnetName, properties: {
          addressPrefix: subnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        } }
    ]
  }
}

module privateDnsZones './modules/private-dns-zone.bicep' = [for dnsZoneName in dnsZonesNames: {
  name: dnsZoneName
  params: {
    name: dnsZoneName
    vnetName: vnetName
    tags: {
      privateLink: 'true'
    }
  }
  dependsOn: [
    vnet
  ]
}]
