@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param name string

@description('Provide a tier of the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Provide a location for the container resources.')
param location string = resourceGroup().location

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
    // policies: {
    //   quarantinePolicy: {
    //     status: 'disabled'
    //   }
    //   trustPolicy: {
    //     status: 'disabled'
    //   }
    //   softDeletePolicy: {
    //     status: 'enabled'
    //     retentionDays: 7
    //   }
    //   retentionPolicy: {
    //     status: 'enabled'
    //     days: 7
    //   }
    // }
  }
}

output id string = acrResource.id
output loginServer string = acrResource.properties.loginServer
