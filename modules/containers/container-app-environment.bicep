@minLength(5)
@maxLength(50)
@description('Provide a name of your Container App Environment.')
param name string

@description('Provide a location for the Container App Environment.')
param location string = resourceGroup().location

@description('Provide the log analytics workspace id.')
@secure()
param workspaceId string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(workspaceId, '2023-09-01').customerId
        sharedKey: listKeys(workspaceId, '2023-09-01').primarySharedKey
      }
    }
    zoneRedundant: false
  }
}
