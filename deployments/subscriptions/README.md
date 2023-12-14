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

Deploy a template on subscription level

```bash
az deployment sub create --location <location> --template-file .\role-assignments.bicep  --parameters .\role-assignments.bicepparam
```

Deploy a template on group level

```bash
az deployment deployment group create --resource-group <RG> --template-file .\role-assignments.bicep  --parameters .\role-assignments.bicepparam
```

## Templates

- [role-assignments.bicep](.\role-assignments.bicep): A template to deploy role assignments scoped to the deployment
