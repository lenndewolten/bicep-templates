# Deployments

## Setup

Login

```ps
az login
```

Optional: set default subscription

```ps
az account set --name <nameorid>
```

Set variables, adjust values where needed:

```ps
$rg = 'private-storageaccount'
$location = 'northeurope'
$template = '.\private-storage-account.bicep'
$parameters = '.\private-storage-account.bicepparam'
```

Create a resource group:

```ps
az group create -n $rg --location $location
```

Deploy a template

```ps
az deployment group create --resource-group $rg --template-file $template --parameters $parameters
```

## Templates

- [private-storage-account.bicep](private-storage-account.bicep): This template sets up a private storage account with multiple private endpoint connections for table, queue and blob. Please ensure an Azure Private DNS Zone is created before proceeding with the deployment, see [private-network.bicep](../../networking/private-network.bicep).
