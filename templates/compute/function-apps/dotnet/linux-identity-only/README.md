# Deployments

## Setup

Login

```powershell
az login
```

Optional: set default subscription

```powershell
az account set --name <nameorid>
```

Set variables, adjust values where needed:

```powershell
$rg = 'tothemoonandback'
$location = 'northeurope'
$template = '.\functionapp.bicep'
$parameters = '.\functionapp.bicepparam'
$storageAccountName = 'appv7p4wnstorage'
$functionAppName = 'appv7p4wn'
```

Create a resource group:

```powershell
az group create -n $rg --location $location
```

Deploy a template:

```bash
az deployment group create --resource-group $rg --template-file $template  --parameters $parameters
```

## Templates

- [functionapp.bicep](functionapp.bicep): This template sets up a DotNet Function app on a Linux consumption (serverless) plan in Azure. The app uses RBAC in favor of SAS keys to authenticate the function app to the linked storage account

## Deploy the app

### DotNet Function app

If not yet done, deploy the azure resources:

```powershell
az deployment group create --resource-group $rg --template-file $template  --parameters $parameters
```

Navigate to the sample app

```powershell
dotnet publish -c Release -o ./publish
```

Zip the code:

```powershell
$compress = @{
    Path             = ".\publish\*"
    CompressionLevel = "Fastest"
    DestinationPath  = "function_app.zip"
}
Compress-Archive @compress -Force
```

Upload the zip file to the deployed storage account:

```powershell
az storage blob upload --account-name $storageAccountName --auth-mode login --container-name 'appcontainer' --name "app.zip" --file "function_app.zip" --overwrite
```

Set the `WEBSITE_RUN_FROM_PACKAGE=<url>` in the app config with the blob url

```powershell
az functionapp config appsettings set --name $functionAppName --resource-group $rg --settings "WEBSITE_RUN_FROM_PACKAGE=https://$storageAccountName.blob.core.windows.net/appcontainer/app.zip"
```
