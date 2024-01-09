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
param vmAdminUsername string

@description('Password for the Virtual Machine. The password must be at least 12 characters long and have lower case, upper characters, digit and a special character (Regex match)')
@secure()
param vmAdminPassword string

var vmName = take('${vmNamePrefix}${uniqueString(resourceGroup().id)}', 15)

var vnetAddressPrefix = '10.0.0.0/16'

var _defaultSubnet = {
  name: 'default'
  addressPrefix: '10.0.0.0/24'
}
var _azureBastionSubnet = {
  name: 'AzureBastionSubnet'
  addressPrefix: '10.0.1.0/26'
}

var dnsZoneNameMapping = {
  blob: '.blob.${environment().suffixes.storage}'
  file: '.file.${environment().suffixes.storage}'
  table: '.table.${environment().suffixes.storage}'
  queue: '.queue.${environment().suffixes.storage}'
  sqlServer: environment().suffixes.sqlServerHostname
}
var dnsZonesNames = [for resource in privateLinkSubResources: 'privatelink${dnsZoneNameMapping[resource]}']

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
      {
        name: _defaultSubnet.name
        properties: {
          addressPrefix: _defaultSubnet.addressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: _azureBastionSubnet.name
        properties: {
          addressPrefix: _azureBastionSubnet.addressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
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

resource azureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: vnet
  name: _azureBastionSubnet.name
}

resource azureBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${bastionName}-publicip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    disableCopyPaste: false
    ipConfigurations: [
      {
        name: 'IpConfig'
        properties: {
          publicIPAddress: {
            id: azureBastionPublicIpAddress.id
          }
          subnet: {
            id: azureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: vnet
  name: _defaultSubnet.name
}

resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${vmName}-NetInt'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: defaultSubnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'TestVm'
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
      osDisk: {
        name: 'TestVmOsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.id
        }
      ]
    }
  }
}
