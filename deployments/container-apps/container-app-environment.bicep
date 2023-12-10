@description('Provide a location for the container resources.')
param location string = resourceGroup().location

@minLength(5)
@maxLength(50)
@description('Provide a name of your Container App Environment.')
param containerAppEnvName string

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('Provide role assignments of your Azure Container Registry.')
param acrRoles array = []

@minLength(5)
@maxLength(50)
@description('Provide a name of your Log Analytics workspace.')
param workspaceName string

module workspace '../../modules/log-analytics/workspace.bicep' = {
  name: '${deployment().name}-workspace'
  params: {
    name: workspaceName
    location: location
  }
}

module acr '../../modules/containers/container-registry.bicep' = {
  name: '${deployment().name}-acr'
  params: {
    name: acrName
    location: location
    sku: acrSku
  }
}

module containerAppEnv '../../modules/containers/container-app-environment.bicep' = {
  name: '${deployment().name}-container-app-env'
  params: {
    name: containerAppEnvName
    location: location
    workspaceId: workspace.outputs.id
  }
}

resource acrRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for identity in acrRoles: {
  name: guid(resourceGroup().id, identity.principalId, identity.roleDefinitionId)
  dependsOn: [
    acr
  ]
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', identity.roleDefinitionId)
    principalId: identity.principalId
    principalType: identity.principalType
  }
}]
