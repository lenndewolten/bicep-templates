@description('Provide a name for the VM.')
param name string

@description('Provide a location for the VM.')
param location string = resourceGroup().location

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

@description('Specifies the name of the administrator account. This property cannot be updated after the VM is created.')
param adminUsername string

@description('Specifies the password of the administrator account.')
@secure()
param adminPassword string

@description('Specifies information about the image to use.')
param imageReference object = {
  publisher: 'microsoftwindowsdesktop'
  offer: 'windows-11'
  sku: 'win11-22h2-pro'
  version: 'latest'
}

@description('Specifies the storage account type for the managed disk.')
param osDiskType string = 'StandardSSD_LRS'

@description('Provide a subnet ID to bound to the IP configuration.')
param subnetId string

@description('Resource tags for all the VM resources.')
param tags object = {}

var publicIpAddressName = '${name}PublicIP'
var networkInterfaceName = '${name}NetInt'

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIpAddressName
  location: location
  tags: {
    displayName: publicIpAddressName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${name}OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
