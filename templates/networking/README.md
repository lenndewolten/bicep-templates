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
$rg = 'private-network'
$location = 'northeurope'
$adminPassword = 'Th3B3stPa$$word!'
$template = '.\private-network.bicep'
$parameters = '.\private-network.bicepparam'
```

Create a resource group:

```ps
az group create -n $rg --location $location
```

Deploy a template

```ps
az deployment group create --resource-group $rg --template-file $template --parameters $parameters --parameters vmAdminPassword=$adminPassword
```

## Templates

- [private-network.bicep](private-network.bicep): This template sets up a VNET, one or more Private DNS Zones, VM that can be used as a jumpbox and an Azure Bastion host.
  You can use this network to deploy private resources like:
  - SQL server: [private-storage-account.bicep.bicep](../storage/storageaccount/private-storage-account.bicep)
  - Storage account: [private-sql-server.bicep](../storage/sql/private-sql-server.bicep)
