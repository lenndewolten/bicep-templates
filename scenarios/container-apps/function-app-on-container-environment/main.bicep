@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide a prefix for the resources.')
@minLength(5)
param resourceNamePrefix string

var envResourceNamePrefix = toLower(resourceNamePrefix)

module storageAccount '../../../shared/storage-account.bicep' = {
  name: 'storageaccount-${envResourceNamePrefix}'
  params: {
    name: '${envResourceNamePrefix}strg'
    sku: 'Standard_LRS'
    fileServices: {}
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${envResourceNamePrefix}-la'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${envResourceNamePrefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

module functionApp './modules/functionapp.bicep' = {
  name: 'function-app'
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppEnvRG: containerAppEnvRG
    functionAppName: '${envResourceNamePrefix}-funcapp'
    storageAccountName: storageAccount.outputs.name
    appInsightsName: appInsights.name
  }
}
