# Prerequisites

## Introduction

As these labs are using Terraform as example code, there is a requirement to create: 
- a Terraform remote state store
- a Service Principal with permissions to deploy resources

Before you get started with, I recommend following the [automation prerequisites](https://azurecitadel.com/automation/prereqs/) to set up your machine.

### Quick start

Full instructions for prerequisites are below, or you can use the `build.sh` script to build the environment requirements.

1. [Log in to Azure Cloud Shell with Bash](https://docs.microsoft.com/en-gb/azure/cloud-shell/quickstart)
2. Target the subscription to deploy the test environment using the `az account set --subscription 0000-0000-0000-0000-0000` command.
3. Run the `build.sh` script from the [scripts](../scripts/) folder.

The output should look similar to this. **Keep the keys secure as they grant access Contributor access to the Azure subscription and access to the storage account.** These keys will be needed later and stored in GitHub secrets.

```json
Environment variables for GitHub secrets:
{
  "ARM_ACCESS_KEY": "XeYqhNRv1nNpCqRIwHLsQEcI+8jHyLkRaWJQI2C0wYMg9w4rbmmCKkiVe2P+lNNQhVNk+1Vy1wzt6HgQNewocSg==",
  "ARM_CLIENT_ID": "0a00a0aa-aaa0-0000-aa0a-a0000000aa0a",
  "ARM_CLIENT_SECRET": "1,.p/qXD~~rVF(na`$uUzX5TiH+`GL|k",
  "ARM_SUBSCRIPTION_ID": "00000a00-0aa0-000a-a000-0a00000a0a0a",
  "ARM_TENANT_ID": "00a000aa-00a0-00aa-00aa-0a0aa000aa00"
}
```

> Note: The output will be needed later for the GitHub secrets

## Full instructions

### Terraform remote state storage

This lab uses a Terraform build pipeline in GitHub Actions. To ensure correct state handling, a remote Terraform state should be used. We will set up a `azurerm` backend, which will store `.tfstate` files in an Azure storage account. 

To simplify the instructions, you may create environment variables to reuse common inputs:

```bash
resource_group_name="citadeldemo-tfstate-rg"
storage_account_name="citadeldemotfstatestg" #note: change this name, it must be unique
container_name="tfstate"
location="uksouth"
```

1. Create a resource group

```bash
az group create --name $resource_group_name --location $location
```

2. Create a storage account, container and export a storage account key

```bash
az storage account create --name $storage_account_name --resource-group $resource_group_name --kind StorageV2 --sku Standard_LRS
```

3. Create a container within the storage account

```bash
az storage container create --name $container_name --account-name $storage_account_name
```

4. Export one of the storage account keys

```bash
az storage account keys list --account-name $storage_account_name --output tsv --query [0].value
```

The output should look similar to this. **Keep the keys secure as they grant access to the storage account.** One of the `value` keys will be needed later to store in GitHub secrets.

```json
[
  {
    "keyName": "key1",
    "permissions": "Full",
    "value": "XeYqhNRv1nNpCqRIwHLsQEcI+8jHyLkRaWJQI2C0wYMg9w4rbmmCKkiVe2P+lNNQhVNk+1Vy1wzt6HgQNewocSg=="
  },
  {
    "keyName": "key2",
    "permissions": "Full",
    "value": "1lOde6ycP1+r3eHk8rH2OyX3ppdSmo+x/KBoJAAmYqOyEZ9EQpv/nQuaMu4pqSdnKHbRme6PyjCNpUh/jT5jhA=="
  }
]
```

> Note: This key will be needed later for the `ARM_ACCESS_KEY` GitHub secret.

> *Learn more at [Terraform Docs - Backend Type: azurerm](https://www.terraform.io/docs/backends/types/azurerm.html).*


### Service principal

Terraform requires RBAC permission to deploy resources to Azure. This example will create a Service Principal with [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) permissions to the active Azure subscription.

To simplify the instructions, you may create environment variables to reuse common inputs:

```bash
service_principal_name="citadeldemo-sp"
```

5. Create a service principal with Contributor permissions

```bash
az ad sp create-for-rbac --name $service_principal_name
```
The output should look similar to this. **Keep the keys secure as they grant access Contributor access to the Azure subscription.** `appId`, `password` and `tenant` will be needed later and stored in GitHub secrets.

```json
{
  "appId": "0a00a0aa-aaa0-0000-aa0a-a0000000aa0a",
  "displayName": "citadeldemo-sp",
  "name": "http://citadeldemo-sp",
  "password": "1,.p/qXD~~rVF(na`$uUzX5TiH+`GL|k",
  "tenant": "00a000aa-00a0-00aa-00aa-0a0aa000aa00"
}
```

> Note: The `create-for-rbac` command will create a default role assignment of [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor).

> Note: The output will be needed later for the GitHub secrets

> *Learn more at [Microsoft Docs - Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli).*

### Subscription ID

Terraform needs to know the Azure subscription to deploy resources. This can be copied from the Azure Portal, or as we are already using CLI we can retrieve the current subscription information.

6. List Azure subscriptions

```bash
az account list --output table
```

The output should look similar to this. The current subscription should be tagged with `isDefault` equals `true` (in the example below, it is *Azure Subscription 1*). `subscriptionId` will be needed later and stored in GitHub secrets.

```bash
Name                    CloudName    SubscriptionId                        State    IsDefault
----------------------  -----------  ------------------------------------  -------  -----------
Azure Subscription 1    AzureCloud   00000a00-0aa0-000a-a000-0a00000a0a0a  Enabled  True
Azure Subscription 2    AzureCloud   0000aa0a-aa00-0000-a0aa-00a00aa000aa  Enabled  False
Azure Subscription 3    AzureCloud   0000aa0a-aa40-0000-a0aa-00a00aa000aa  Enabled  False
```

> Note: The output will be needed later for the GitHub secrets

## End of Lab 1

At the end of this lab, you should have
- A storage account to store Terraform remote state
- A service principal with access to create resources in an Azure subscription
- The following keys will be required later in the labs:
    - A storage account access key `value`
    - Service principal `appId`
    - Service principal `password`
    - The `subscriptionId` of the Azure subscription
    - The `tenant` ID for your organization

Proceed to [Lab 2: Prepare a GitHub repository](./2-prepare-a-github-repository/).

