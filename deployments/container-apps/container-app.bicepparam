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
  targetPort: 443
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

param roleAssignments = [
  {
    roleDefinitionId: '17d1049b-9a84-46fb-8f53-869881c3d3ab' // STORAGE ACCOUNT CONTRIBUTOR
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
  {
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // BLOB DATA OWNER
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
  {
    roleDefinitionId: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // QUEUE DATA CONTRIBUTOR
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
  {
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // TABLE DATA CONTRIBUTOR
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
]
