@export()
type Kind = 'functionapp,linux' | 'functionapp,linux,container,azurecontainerapps'

@export()
type SiteConfig = {
  @description('Linux App Framework and version')
  linuxFxVersion: string
  acrUserManagedIdentityID: string?
  acrUseManagedIdentityCreds: bool?
  minimumElasticInstanceCount: int?
  functionAppScaleLimit: int?
  appSettings: AppSetting[]?
}

type AppSetting = {
  name: string
  value: string
}

@export()
type StorageAccountProperties = {
  name: string
  resourceGroup: string?
}

@export()
type ApplicationInsightsProperties = {
  name: string
  resourceGroup: string?
}
