import { RegistryCredentials } from '../../../../types/container-app.bicep'

@description('Therivate registries to be used by the container app')
param registries RegistryParam[]

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

module containerApp_identity_acrPullRole '../../../../shared/role-assignments.bicep' = [
  for registry in registries: {
    name: 'container-app-acr-access-${registry.name}'
    scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
    params: {
      principalId: registry.identity.principalId
      roleDefinitionId: acrPullRole
    }
  }
]

resource _registries 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = [
  for registry in registries: {
    name: registry.name
    scope: resourceGroup(registry.resourceGroup ?? resourceGroup().name)
  }
]

output registries RegistryCredentials[] = [
  for (registry, i) in registries: {
    server: _registries[i].properties.loginServer
    identity: registry.identity.resourceId
  }
]

type RegistryParam = {
  name: string
  identity: {
    resourceId: string
    principalId: string
  }
  resourceGroup: string?
}
