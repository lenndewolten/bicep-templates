@description('Provide a location for the resources.')
param location string = resourceGroup().location

@description('The name of the vnet.')
param vnetName string

@description('The name of the vm subnet.')
param vmSubnetName string

@description('The name of the bastion subnet.')
param bastionSubnetName string

@description('The name of the azure bastion.')
param bastionName string

@description('The name of the virtual machine.')
param vmName string

@description('Username for the Virtual Machine.')
param vmAdminUsername string

@description('Password for the Virtual Machine. The password must be at least 12 characters long and have lower case, upper characters, digit and a special character (Regex match)')
@secure()
param vmAdminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource azureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: bastionSubnetName
}

resource azureBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: '${bastionName}-publicip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-11-01' = {
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

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: vmSubnetName
}

resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vmName}-NetInt'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnet.id
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
