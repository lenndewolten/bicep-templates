@export()
type FileService = {}

@export()
type BlobService = {
  restorePolicy: {
    enabled: bool
  }?
  deleteRetentionPolicy: {
    enabled: bool
  }?
  containerDeleteRetentionPolicy: {
    enabled: bool
  }?
  changeFeed: {
    enabled: bool
  }?
  isVersioningEnabled: bool?
}

@export()
type TableService = {}

@export()
type QueueService = {
  queues: QueueProperties[]?
}

type QueueProperties = {
  name: string
}
