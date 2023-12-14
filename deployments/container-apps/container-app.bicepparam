using 'container-app.bicep'

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
  targetPort: 8080
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
    image: 'lenndewoltentestacr.azurecr.io/containerapps-storageaccount:v2'
    name: 'hello-world-container'
    resources: {
      cpu: json('0.25')
      memory: '0.5Gi'
    }
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
