
using 'main.bicep'

param containerAppEnvName = 'my-container-app-env'
param containerAppEnvRG = 'container-apps'

param acrName = 'lenndewoltentestacr'
param acrRG = 'container-apps'

param containerAppName = 'my-test-container-app'
param storageAccountName = 'lenntstchtrappfilestrg'

param image = {
  repository: 'containerapps-helloworld'
  tag: 'latest'
}

param resources = {
  cpu: '0.5'
  memory: '1Gi'
}
