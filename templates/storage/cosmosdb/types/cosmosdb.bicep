@export()
type Container = {
  name: string
  partitionKey: ContainerPartitionKey
  compositeIndexes: CompositePath[][]?
}

@export()
type ContainerPartitionKey = {
  kind: 'Hash' | 'MultiHash' | 'Range'
  paths: string[]
}

@export()
type CompositePath = {
  path: string
  order: 'ascending' | 'descending'
}

@export()
type RoleAssignments = {
  roleDefinitionId: string
  principalId: string
  principalType: 'ServicePrincipal' | 'User' | 'Group'
}
