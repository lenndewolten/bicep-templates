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
