#! /bin/bash

# Input variables

export AZURE_DEFAULTS_GROUP=citadel-github-actions
export AZURE_DEFAULTS_LOCATION=uksouth

container_name=tfstate
service_principal_name=citadel-github-actions-sp

# Create resource group
echo -e "\e[0;33mCreating (or updating) the resource group...\e[0m"
az group create --name $AZURE_DEFAULTS_GROUP
echo -e "\e[1;34mAZURE_DEFAULTS_GROUP\e[1;37m: \e[0;32m$AZURE_DEFAULTS_GROUP\e[0m"


# Check for existing storage account name starting with gha
existing_storage_account=$(az storage account list --query "[?starts_with(name, 'gha')].name" --output tsv)
if [[ -n "$existing_storage_account" ]]
then
  # Use existing storage account name
  export AZURE_STORAGE_ACCOUNT=$existing_storage_account
  echo -e "\n\e[0;33mUsing existing storage account...\e[0m"
  echo -e "\e[1;34mAZURE_STORAGE_ACCOUNT\e[1;37m: \e[0;32m$AZURE_STORAGE_ACCOUNT\e[0m"
else
  # Generate unique name and create storage account for Terraform remote state
  export AZURE_STORAGE_ACCOUNT=gha$(tr -dc "[:lower:][:digit:]" < /dev/urandom | head -c 16)
  echo -e "\n\e[0;33mCreating storage account...\e[0m"
  az storage account create --name $AZURE_STORAGE_ACCOUNT --kind StorageV2 --sku Standard_LRS
  echo -e "\e[1;34mAZURE_STORAGE_ACCOUNT\e[1;37m: \e[0;32m$AZURE_STORAGE_ACCOUNT\e[0m"
fi

# Grab the key
echo -e "\n\e[0;33mStorage account key...\e[0m"
export AZURE_STORAGE_KEY=$(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT --output tsv --query [0].value)
echo -e "\e[1;34mAZURE_STORAGE_KEY\e[1;37m: \e[0;32m$AZURE_STORAGE_KEY\e[0m"

# Create container
echo -e "\n\e[0;33mCreating container...\e[0m"
az storage container create --name $container_name
echo -e "\e[1;34mContainer\e[1;37m: \e[0;32m$container_name\e[0m"

# Create service principal with Contributor permissions
echo -e "\n\e[0;33mCreating service principal..."
service_principal_output=$(az ad sp create-for-rbac --name "https://$service_principal_name")
service_principal_app_id=$(echo $service_principal_output | jq -r '.appId')
service_principal_name=$(echo $service_principal_output | jq -r '.name')
service_principal_password=$(echo $service_principal_output | jq -r '.password')
service_principal_tenant=$(echo $service_principal_output | jq -r '.tenant')
echo -e "\n\e[0;33mService principal object:\e[0m"
echo $service_principal_output | jq

# Get current subscription id
echo -e "\n\e[0;33mChecking current subscription...\e[0m"
subscription_name=$(az account show --output tsv --query name)
subscription_id=$(az account show --output tsv --query id)
echo -e "\e[0;33mCurrent subscription:\e[0m"
echo -e "\e[1;34msubscriptionName\e[1;37m: \e[0;32m$subscription_name\e[0m"
echo -e "\e[1;34msubscriptionId\e[1;37m:   \e[0;32m$subscription_id\e[0m"

# Print output for GitHub secrets
echo -e "\n\e[0;33mEnvironment variables for GitHub secrets:\e[0m"
echo -e "\e[1;34mARM_ACCESS_KEY\e[1;37m:      \e[0;32m$AZURE_STORAGE_KEY\e[0m"
echo -e "\e[1;34mARM_CLIENT_ID\e[1;37m:       \e[0;32m$service_principal_app_id\e[0m"
echo -e "\e[1;34mARM_CLIENT_SECRET\e[1;37m:   \e[0;32m$service_principal_password\e[0m"
echo -e "\e[1;34mARM_SUBSCRIPTION_ID\e[1;37m: \e[0;32m$subscription_id\e[0m"
echo -e "\e[1;34mARM_TENANT_ID\e[1;37m:       \e[0;32m$service_principal_tenant\e[0m\n"

# Print example terraform backend block

echo -e "\n\e[0;33mExample terraform provider.tf including azurerm backend:\e[0m"
setterm --foreground green
cat - <<EOF
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "$AZURE_STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  version =  "~> 2.20"
}
EOF
setterm --foreground default
echo