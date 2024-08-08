type Sku = {
  name: 'Basic' | 'GP_S_Gen5_1'
  tier: 'Basic' | 'GeneralPurpose'
  capacity: int?
}

type FreeLimitExhaustionBehavior = 'AutoPause' | 'BillOverUsage'

@export()
type Database = {
  name: string
  sku: Sku
  collation: string?
  maxSizeBytes: int?
  sampleName: string?
  autoPauseDelay: int?
  useFreeLimit: bool?
  freeLimitExhaustionBehavior: 'AutoPause' | 'BillOverUsage'?
}
