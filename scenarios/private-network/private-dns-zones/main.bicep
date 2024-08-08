@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the vnet.')
param vnetName string

@description('The private link subresources for automatic CNAME resolution to be linked to the vnet. See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#commercial')
@allowed([
  'blob'
  'file'
  'queue'
  'table'
  'sqlServer'
])
param privateLinkSubResources array = []

@description('The name of the azure bastion.')
param bastionName string = 'bastionhost'

@description('The name prefix of the VM.')
param vmNamePrefix string = 'jumpbox'

@description('Username for the Virtual Machine.')
param vmAdminUsername string?

@description('Password for the Virtual Machine. The password must be at least 12 characters long and have lower case, upper characters, digit and a special character (Regex match)')
@secure()
param vmAdminPassword string?

var vmName = take('${vmNamePrefix}${uniqueString(resourceGroup().id)}', 15)
var deployJumpbox = vmAdminUsername != null && vmAdminPassword != null

var vnetAddressPrefix = '10.0.0.0/16'

var _defaultSubnet = {
  name: 'default'
  addressPrefix: '10.0.0.0/24'
}
var _azureBastionSubnet = {
  name: 'AzureBastionSubnet'
  addressPrefix: '10.0.1.0/26'
}

var subnets = concat([_defaultSubnet], deployJumpbox ? [_azureBastionSubnet] : [])

var dnsZoneNameMapping = {
  blob: '.blob.${environment().suffixes.storage}'
  file: '.file.${environment().suffixes.storage}'
  table: '.table.${environment().suffixes.storage}'
  queue: '.queue.${environment().suffixes.storage}'
  sqlServer: environment().suffixes.sqlServerHostname
}
var dnsZonesNames = [for resource in privateLinkSubResources: 'privatelink${dnsZoneNameMapping[resource]}']

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
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

module privateDnsZones './modules/private-dns-zone.bicep' = [
  for dnsZoneName in dnsZonesNames: {
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
  }
]

module jumpbox './modules/jumpbox.bicep' = if (deployJumpbox) {
  name: 'jumpbox'
  params: {
    vmName: vmName
    location: location
    vnetName: vnetName
    vmSubnetName: _defaultSubnet.name
    vmAdminUsername: vmAdminUsername!
    vmAdminPassword: vmAdminPassword!
    bastionName: bastionName
    bastionSubnetName: _azureBastionSubnet.name
  }
  dependsOn: [
    vnet
  ]
}
