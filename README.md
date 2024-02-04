# Bicep Templates

This repository contains a collection of [Bicep](https://github.com/Azure/bicep) templates for deploying infrastructure on Microsoft Azure. Bicep is a domain-specific language (DSL) for deploying Azure resources declaratively.

## Getting Started

### 1. Clone the Repository:

```bash
git clone https://github.com/lenndewolten/bicep-templates.git
```

### 2. Navigate to the Template Directory:

```bash
cd templates
```

### 3. Deploy a Template:

Use the `az deployment` command to deploy a specific template. For example:

```bash
az deployment group create --resource-group <ResourceGroupName> --template-file <TemplateName.bicep> --parameters <ParamName.bicepparam>
```

Replace `<ResourceGroupName>` with your desired Azure resource group name, `<TemplateName.bicep>` with the name of the Bicep template you want to deploy, and `<ParamName.bicepparam>` with the parameter file.

## Templates

- **Container Apps:** Templates to set up a containerized application environment in Azure.
- **Function Apps:** Templates to set up function apps in Azure.
- **Networking:** Templates to set up a private network, including private DNS zones and private endpoints with the corresponding Azure storage resources
- **Subscription:** Template to set up subscription wide RBAC role assignment for a user (ME!)

## Contributing

If you would like to contribute to this repository, feel free to submit a pull request.

## License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.

Happy deploying!
