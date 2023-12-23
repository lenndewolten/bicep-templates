@description('Provide a location for the private endpoint.')
param location string = resourceGroup().location

@description('The name of the subnet.')
param privateLinkServiceId string

@description('The name of the resource group.')
param vnetRsourceGroup string

@description('The name of the private dns zone.')
param privateDnsZoneName string

param privateEndpointName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
  scope: resourceGroup(vnetRsourceGroup)
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: privateDnsZoneName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}
