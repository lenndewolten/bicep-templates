@description('Provide a name for the container environment.')
param containerAppEnvName string
param name string

@secure()
param accountKey string
param accountName string
param shareName string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
}

resource filesShare 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: name
  parent: containerAppEnv
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountKey: accountKey
      accountName: accountName
      shareName: shareName
    }
  }
}

output filesShareLinkName string = filesShare.name
