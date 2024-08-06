using 'main.bicep'

param containerAppEnvName = 'my-container-app-env'
param containerAppEnvRG = 'my-container-apps'

param acrName = 'lenndewoltentestacr'
param acrRG = 'my-container-apps'

param storageAccountName = 'mycontainerappstorage'

param containerAppName = 'my-container-app'
param ingress = {
  allowInsecure: false
  clientCertificateMode: 'ignore'
  external: true
  targetPort: 80
  transport: 'auto'
  traffic: [
    {
      latestRevision: true
      weight: 100
    }
  ]
}
param containers = [
  {
    image: 'lenndewoltentestacr.azurecr.io/containerapps-helloworld:latest'
    name: 'hello-world-container'
    resources: {
      cpu: json('0.25')
      memory: '0.5Gi'
    }
    env: [
      {
        name: 'TEST_VAR1'
        value: 'hello world'
      }
    ]
  }
]
param scale = {
  minReplicas: 1
  maxReplicas: 2
  rules: [
    {
      name: 'http-requests'
      http: {
        metadata: {
          concurrentRequests: '10'
        }
      }
    }
  ]
}
