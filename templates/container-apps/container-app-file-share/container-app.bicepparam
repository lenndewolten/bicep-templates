using 'container-app.bicep'

param containerAppEnvName = 'my-container-app-env'
param containerAppEnvRG = 'my-container-apps'

param acrName = 'lenndewoltentestacr'
param acrRG = 'my-container-apps'

param containerAppName = 'my-test-container-app'
param storageAccountName = 'lenntstchtrappfilestrg'

param image = {
  repository: 'containerapps-helloworld'
  tag: 'latest'
}
