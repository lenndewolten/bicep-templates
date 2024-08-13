import { Container, Ingress, Volumn, RegistryCredentials, Secret, Scale } from '../types/container-app.bicep'
import { ManagedServiceIdentity } from '../types/rbac.bicep'

@minLength(5)
@maxLength(50)
@description('Provide a name of your Container App Environment.')
param name string

@description('Provide a location for the Container App Environment.')
param location string = resourceGroup().location

@description('Provide a name for the container environment.')
param containerAppEnvName string
@description('Provide the resource group for the container environment.')
param containerAppEnvRG string = resourceGroup().name

@description('Provide a identity for the container app.')
param identity ManagedServiceIdentity = { type: 'None' }

@description('Provide private registries for the container app if applicable.')
param registries RegistryCredentials[] = []

@description('Provide the ingress for the container app')
param ingress Ingress

@description('Provide an array of containers for the container app')
param containers Container[]

@description('Provide the scale for the container app.')
param scale Scale

@description('Provide the volumes for the container app')
param volumes Volumn[] = []

@description('Provide the secrets for the container app')
param secrets Secret[] = []

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvName
  scope: resourceGroup(containerAppEnvRG)
}

func filterOutCustomProperties(container Container) object =>
  intersection(
    container,
    union(container, { registry: { name: uniqueString(container.name), loginServer: uniqueString(container.name) } })
  )

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  identity: identity
  properties: {
    configuration: {
      ingress: ingress
      registries: registries
      secrets: map(secrets, secret => {
        name: replace(toLower(secret.name), '_', '-')
        value: secret.value
      })
    }
    environmentId: containerAppEnv.id
    template: {
      containers: [
        for container in containers: union(filterOutCustomProperties(container), {
          image: container.registry.?name != null
            ? '${filter(registries, reg => contains(reg.server, container.registry.name! ))[0].server }/${container.image}'
            : '${container.registry.loginServer}/${container.image}'
          resources: {
            cpu: json(container.resources.cpu)
            memory: container.resources.memory
          }
          env: concat(
            container.?env ?? [],
            map(secrets, secret => {
              name: secret.name
              secretRef: replace(toLower(secret.name), '_', '-')
            })
          )
        })
      ]
      scale: scale
      volumes: volumes
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
