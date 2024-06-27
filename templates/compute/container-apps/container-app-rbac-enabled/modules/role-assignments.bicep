@description('The principalId of the identity.')
param principalId string

@description('The id of the role.')
param roleDefinitionId string

@description('The principalType of the identity.')
param principalType string = 'ServicePrincipal'

var role = resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    roleDefinitionId: role
    principalId: principalId
    principalType: principalType
  }
}
