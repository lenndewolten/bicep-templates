type Resource = {
  cpu: string
  memory: string
}

type Image = {
  repository: string
  tag: string
}

type EnvironmentVariable = {
  name: string
  value: string?
  secretRef: string?
}

type VolumeMount = {
  mountPath: string
  volumeName: string
}

@export()
type Container = {
  registry: Registry
  image: string
  name: string
  resources: Resource
  env: EnvironmentVariable[]?
  volumeMounts: VolumeMount[]?
}

type Traffic = {
  latestRevision: bool
  weight: int
}

@export()
type Volumn = {
  name: string
  storageName: string
  storageType: 'AzureFile'
}

@export()
type Ingress = {
  allowInsecure: bool?
  clientCertificateMode: string?
  external: bool
  targetPort: int
  transport: ('auto' | 'http' | 'http2' | 'tcp')?
  traffic: Traffic[]?
}
@export()
type Registry = {
  name: string?
  loginServer: string?
}

@export()
type RegistryCredentials = {
  identity: string
  server: string
}

@export()
type Secret = {
  name: string
  @secure()
  value: string
}

@export()
type Scale = {
  minReplicas: int
  maxReplicas: int
  rules: ScaleRule[]
}

type ScaleRule = {
  name: string
  http: {
    metadata: {
      concurrentRequests: string
    }
  }?
  azureQueue: {
    queueLength: int
    queueName: string
    auth: ScaleRuleAuth[]
  }?
  custom: {
    auth: ScaleRuleAuth[]
    type: string
    metadata: object
  }?
}

type ScaleRuleAuth = {
  secretRef: string
  triggerParameter: string
}
