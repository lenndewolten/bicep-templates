@minLength(5)
@maxLength(50)
@description('Provide a name of your Log Analytics workspace.')
param name string

@description('Provide a location for the workspace.')
param location string = resourceGroup().location

resource logAnalystics_workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    features: {
      immediatePurgeDataOn30Days: true
    }
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 2
    }
  }
}

output id string = logAnalystics_workspace.id
output customerId string = logAnalystics_workspace.properties.customerId
