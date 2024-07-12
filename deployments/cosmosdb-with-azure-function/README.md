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
$rg = 'tothemoonandback'
$location = 'northeurope'
$template = '.\deployment.bicep'
$parameters = '.\deployment.bicepparam'
```

Create a resource group:

```ps
az group create -n $rg --location $location
```

Deploy a template

```ps
az deployment group create --resource-group $rg --template-file $template --parameters $parameters
```
