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
az group create --location eastus --resource-group <your-rg>
```

Deploy a template

```bash
az deployment group create --resource-group <your-rg> --template-file .\private-network.bicep  --parameters .\private-network.bicepparam
```

## Templates

- [private-network.bicep](private-network.bicep): This template sets up a VNET, one or more Private DNS Zones, VM that can be used as a jumpbox and an Azure Bastion host.
- [private-sql-server.bicep](private-sql-server.bicep): This template sets up a private SQL server and database with a private endpoint connection.
- [private-storage-account.bicep](private-storage-account.bicep): This template sets up a private storage account with multiple private endpoint connections for table, queue and blob.
