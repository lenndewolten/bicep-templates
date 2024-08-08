@export()
type Container = {
  name: string
  partitionKey: ContainerPartitionKey
  compositeIndexes: CompositePath[][]?
  uniqueKeyPolicy: {
    uniqueKeys: UniqueKey[]
  }?
  autoscaleSettings: {
    maxThroughput: int
  }?
}

type UniqueKey = {
  paths: string[]
}

type ContainerPartitionKey = {
  kind: 'Hash' | 'MultiHash' | 'Range'
  paths: string[]
}

type CompositePath = {
  path: string
  order: 'ascending' | 'descending'
}

@export()
type Location = {
  locationName: string
  failoverPriority: int
  isZoneRedundant: bool
}

@export()
type ConsistencyPolicy = {
  defaultConsistencyLevel: 'BoundedStaleness' | 'ConsistentPrefix' | 'Eventual' | 'Session' | 'Strong'
  maxIntervalInSeconds: int?
  maxStalenessPrefix: int?
}

@export()
type Database = {
  name: string
  autoscaleSettings: {
    maxThroughput: int
  }?
}

@export()
type BackupPolicy = {
  type: 'Periodic' | 'Continuous'
  continuousModeProperties: BackupContinuousModeProperties?
  periodicModeProperties: BackupPeriodicModeProperties?
}

type BackupPeriodicModeProperties = {
  backupIntervalInMinutes: int
  backupRetentionIntervalInHours: int
  backupStorageRedundancy: 'Local' | 'Zone' | 'Geo'
}

type BackupContinuousModeProperties = {
  tier: 'Continuous30Days' | 'Continuous7Days'
}
