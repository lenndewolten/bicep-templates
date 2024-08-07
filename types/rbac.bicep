@export()
type RoleAssignment = {
  roleDefinitionId: string
  principalId: string
  principalType: 'Group' | 'ServicePrincipal' | 'User'
}
