# Deployments

## Setup

Login

```bash
az login
```

Optional: set default subscription

```bash
az account set --name <nameorid>
```

Create a resource group:

```bash
az group create --location eastus --resource-group myfunctionapp
```

Deploy a template:

```bash
az deployment group create --resource-group myfunctionapp --template-file .\python-app.bicep  --parameters .\python-app.bicepparam
```

## Templates

- [python-app.bicep](python-app.bicep): This template sets up a Python Function app on a Linux consumption (serverless) plan in Azure. The app uses RBAC in favor of SAS keys to authenticate the function app to the linked storage account

## Deploy the app

### Python Function app

If not yet done, deploy the azure resources:

```bash
az deployment group create --resource-group myfunctionapp --template-file .\python-app.bicep  --parameters .\python-app.bicepparam
```

Zip the code:

```powershell
$compress = @{
    Path             = ".\app\host.json", ".\app\*.py", ".\app\requirements.txt"
    CompressionLevel = "Fastest"
    DestinationPath  = "function_app.zip"
}
Compress-Archive @compress -Force
```

Upload the zip file to the deployed storage account:

```bash
az storage blob upload --account-name <storage-account-name> --auth-mode login --container-name 'appcontainer' --name "app.zip" --file "function_app.zip" --overwrite
```

Set the `WEBSITE_RUN_FROM_PACKAGE=<url>` in the app config with the blob url

```bash
az functionapp config appsettings set --name $functionName --resource-group $rg --settings "WEBSITE_RUN_FROM_PACKAGE=https://<storage-account-name>.blob.core.windows.net/appcontainer/app.zip"
```
