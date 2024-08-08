
using 'main.bicep'

param containerAppEnvName = 'my-container-app-env'
param containerAppEnvRG = 'container-apps'

param acrName = 'lenndewoltentestacr'
param acrRG = 'container-apps'

param containerAppName = 'my-test-container-app'
param storageAccountName = 'lenntstchtrappfilestrg'

param ingress = {
  external: true
  targetPort: 80
}

param containers = [
  {
    image: 'lenndewoltentestacr.azurecr.io/containerapps-helloworld:latest'
    name: 'hello-world-container'
    resources: {
      cpu: '0.25'
      memory: '0.5Gi'
    }
    env: [
      {
        name: 'FILE_SHARE_PATH'
        value: 'myfileshare'
      }
    ]
    volumeMounts: [
      {
        mountPath: 'myfileshare'
        volumeName: 'myfileshare'
      }
    ]
  }
]
param scale = {
  minReplicas: 0
  maxReplicas: 5
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
