@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide the registry for the function app.')
param registry Registry

@minLength(5)
@description('Provide a name for the resources.')
param applicationName string

var applicationNameLower = toLower(applicationName)

module storageAccount '../../../shared/storage-account.bicep' = {
  name: 'storageaccount'
  params: {
    name: '${applicationNameLower}strg'
    sku: 'Standard_LRS'
    allowSharedKeyAccess: false
    queueServices: {
      queues: [
        {
          name: 'input-queue'
        }
        {
          name: 'output-queue'
        }
      ]
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${applicationNameLower}-la'
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
  name: '${applicationNameLower}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registry.name
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${applicationNameLower}-identity'
  location: location
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

module role_assignments './modules/role_assignments.bicep' = {
  name: 'role_assignments'
  scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  params: {
    principalId: identity.properties.principalId
    registry: registry
  }
}

module functionApp '../../../shared/function-app.bicep' = {
  name: 'function-app'
  dependsOn: [
    role_assignments
  ]
  params: {
    location: location
    functionAppName: '${applicationNameLower}-funcapp'
    kind: 'functionapp,linux,container,azurecontainerapps'
    identityName: identity.name
    managedEnvironmentId: containerAppEnv.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/azurefunctions/quickstart-queue-trigger:isolated8-v1.0.0'
      acrUserManagedIdentityID: identity.id
      acrUseManagedIdentityCreds: true
      minimumElasticInstanceCount: 0
      functionAppScaleLimit: 5
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: acr.properties.loginServer
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ]
    }
    useIdentityOnly: true
    storageAccount: {
      name: storageAccount.outputs.name
    }
    applicationInsights: {
      name: appInsights.name
    }
  }
}

output fqdn string = functionApp.outputs.fqdn
output storageAccountName string = storageAccount.outputs.name

type Registry = {
  name: string
  resourceGroup: string?
}
