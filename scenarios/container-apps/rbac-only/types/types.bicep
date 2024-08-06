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

@export()
type Container = {
  image: string
  name: string
  resources: Resource
  env: EnvironmentVariable[]?
}

type Traffic = {
  latestRevision: bool
  weight: int
}

@export()
type Ingress = {
  allowInsecure: bool?
  clientCertificateMode: string?
  external: bool
  targetPort: int
  transport: string?
  traffic: Traffic[]?
}
