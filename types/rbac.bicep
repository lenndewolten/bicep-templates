@export()
type RoleAssignment = {
  roleDefinitionId: string
  principalId: string
  principalType: 'Group' | 'ServicePrincipal' | 'User'
}

@export()
type ManagedServiceIdentity = {
  type: 'UserAssigned' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'None'
  userAssignedIdentities: object?
}
