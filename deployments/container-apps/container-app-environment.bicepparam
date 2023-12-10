using 'container-app-environment.bicep'

param containerAppEnvName = 'my-container-app-env'
param acrName = 'lenndewoltentestacr'

param acrRoles = [
  {
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // ACR PULL
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
  {
    roleDefinitionId: '8311e382-0749-4cb8-b61a-304f252e45ec' // ACR PUSH
    principalId: '488c3017-5222-4e08-9c1f-10e13bd1a764' // ME
    principalType: 'User'
  }
]
param workspaceName = 'my-container-app-workspace'
