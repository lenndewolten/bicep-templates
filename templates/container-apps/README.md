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
az group create --location eastus --resource-group my-container-apps
```

Register namespaces in the subscription (if needed)

```bash
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

Deploy a template

```bash
az deployment group create --resource-group my-container-apps --template-file .\container-app-environment.bicep  --parameters .\container-app-environment.bicepparam
```

## Templates

- [container-app-environment.bicep](container-app-environment.bicep): This template sets up a containerized application environment in Azure, including a Log Analytics workspace, Azure Container Registry, and an Azure Container App Environment.
- [container-app.bicep](container-app.bicep): The template sets up a containerized application environment with necessary Azure resources, including a managed identity, Azure Container Registry access, container deployment, optional storage account, and specified role assignments.
