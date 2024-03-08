@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string

@description('Provide a name of your Azure Container Registry')
param acrName string
@description('Provide the resource group for the container environment.')
param acrRG string

@description('Provide a name for the container app.')
param containerAppName string

@description('Provide a name of the managed identity.')
param identityName string = '${containerAppName}-identity'

@description('Provide a name for the storage account if applicable.')
param storageAccountName string

@description('Provide the tag of the image used by the app.')
param image Image

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module containerApp_identity_acrPullRole 'modules/role-assignments.bicep' = {
  name: 'container-app-acr-access-${containerAppName}'
  scope: resourceGroup(acrRG)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRole
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: true
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: 'myfileshare'
  parent: fileServices
  properties: {}
}

module fileShareLink 'modules/fileshare.bicep' = {
  name: 'fileshare-link'
  scope: resourceGroup(containerAppEnvRG)
  params: {
    name: 'myfileshare'
    containerAppEnvName: containerAppEnvName
    shareName: fileShare.name
    accountName: storageAccount.name
    accountKey: storageAccount.listKeys().keys[0].value
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
  scope: resourceGroup(acrRG)
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

var targetPort = 80
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  dependsOn: [
    containerApp_identity_acrPullRole
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
      }
      registries: [
        {
          identity: identity.id
          server: acr.properties.loginServer
        }
      ]
    }
    environmentId: containerAppEnv.id
    template: {
      containers: [
        {
          image: '${acr.properties.loginServer}/${image.repository}:${image.tag}'
          name: containerAppName
          resources: {
            cpu: json('2')
            memory: '4Gi'
          }
          env: [
            {
              name: 'FILE_SHARE_PATH'
              value: 'myfileshare'
            }
          ]
          volumeMounts: [
            {
              mountPath: 'myfileshare'
              volumeName: 'myfileshare'
            }
          ]
          probes: []
        }

      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '1'
              }
            }
          }
        ]
      }
      volumes: [
        {
          name: 'myfileshare'
          storageName: fileShareLink.outputs.filesShareLinkName
          storageType: 'AzureFile'
        }
      ]
    }
  }
}

type Image = {
  repository: string
  tag: string
}
