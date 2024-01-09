@description('Provide a location for the private endpoint.')
param location string = resourceGroup().location

@description('The name of the resource group.')
param vnetRsourceGroup string

@description('The name of the private endpoint.')
param privateEndpointName string

@description('The private link subresources for automatic CNAME resolution to be linked to the vnet. See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#commercial')
@allowed([
  'blob'
  'file'
  'queue'
  'table'
  'sqlServer'
])
param privateLinkSubResource string

@description('The id of the subnet to link the private endpoint to.')
param subnetId string

@description('The id of the sub resouce to link the private endpoint to.')
param privateLinkServiceId string

@description('The name of the custom network interface for the private endpoint.')
param customNetworkInterfaceName string = ''

var privateDnsZones = {
  blob: 'privatelink.blob.${environment().suffixes.storage}'
  file: 'privatelink.file.${environment().suffixes.storage}'
  table: 'privatelink.table.${environment().suffixes.storage}'
  queue: 'privatelink.queue.${environment().suffixes.storage}'
  sqlServer: 'privatelink${environment().suffixes.sqlServerHostname}'
}

var privateDnsZoneName = privateDnsZones[privateLinkSubResource]
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: customNetworkInterfaceName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            privateLinkSubResource
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
  scope: resourceGroup(vnetRsourceGroup)
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
