@description('Provide a name for the container environment.')
param containerAppEnvName string
param name string
param storageAccountName string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
}

resource filesShare 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: name
  parent: containerAppEnv
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountKey: storageAccount.listKeys().keys[0].value
      accountName: storageAccountName
      shareName: fileShare.name
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: name
  parent: fileServices
  properties: {}
}

output filesShareLinkName string = filesShare.name
