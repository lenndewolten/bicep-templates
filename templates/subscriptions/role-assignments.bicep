targetScope = 'subscription'

@description('Provide role assignments scoped to the deployment.')
param roleAssignments array = []

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(subscription().id, assignment.principalId, assignment.roleDefinitionId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]
