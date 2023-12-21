@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL logical server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The name the SQL database.')
param databaseName string

@description('The name of the vnet.')
param vnetName string

@description('The name of the subnet.')
param subnetName string = 'default'

@description('The name of the private endpoint.')
param privateEndpointName string

@description('The name prefix of the VM.')
param vmNamePrefix string = 'networktest'

@description('Username for the Virtual Machine.')
param vmAdminUsername string

@description('Password for the Virtual Machine. The password must be at least 12 characters long and have lower case, upper characters, digit and a special character (Regex match)')
@secure()
param vmAdminPassword string

var vnetAddressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'

var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var vmName = take('${vmNamePrefix}${uniqueString(resourceGroup().id)}', 15)

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

var subnetId = first(filter(vnet.properties.subnets, s => s.name == subnetName))!.id

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
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

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    vnet
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: vnetName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: pvtEndpointDnsGroupName
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
  dependsOn: [
    privateEndpoint
  ]
}

module test_virtual_machine 'modules/test-vm.bicep' = {
  name: 'virtual-machine-${vmName}'
  params: {
    name: vmName
    location: location
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetId: subnetId
    tags: {
      environment: 'test'
      name: 'networktest'
    }
  }
}
