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
$rg = 'private-sql'
$location = 'westeurope'
$sqlAdministratorLoginPassword = 'Th3B3stPa$$word!'
$template = '.\private-sql-server.bicep'
$parameters = '.\private-sql-server.bicepparam'
```

Create a resource group:

```ps
az group create -n $rg --location $location
```

Deploy a template

```ps
az deployment group create --resource-group $rg --template-file $template --parameters $parameters --parameters sqlAdministratorLoginPassword=$sqlAdministratorLoginPassword
```

## Templates

- [private-sql-server.bicep](private-sql-server.bicep): This template sets up a private SQL server and database with a private endpoint connection. Please ensure an Azure Private DNS Zone is created before proceeding with the deployment, see [private-network.bicep](../../networking/private-network.bicep).
