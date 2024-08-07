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
  value: string
}

type VolumeMount = {
  mountPath: string
  volumeName: string
}

@export()
type Container = {
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
