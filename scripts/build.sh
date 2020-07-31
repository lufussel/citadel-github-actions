#!/bin/bash

# Input variables
RESOURCE_GROUP_NAME="citadel-actions-state"
STORAGE_ACCOUNT_PREFIX="ctdlgha" #note: max 8 charaacters
CONTAINER_NAME="tfstate"
LOCATION="uksouth"
SERVICE_PRINCIPAL_NAME="http://citadel-actions-sp"

# Create resource group
echo -e "\n\e[0;33mCreating resource account...\e[0m"
echo -e "\e[1;34mRESOURCE_GROUP_NAME\e[1;37m: \e[0;32m$RESOURCE_GROUP_NAME\e[0m"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Check for existing storage account name starting with $STORAGE_ACCOUNT_PREFIX
EXISTING_STORAGE_ACCOUNT=$(az storage account list --query "[?starts_with(name, '$STORAGE_ACCOUNT_PREFIX')].name" --output tsv)
if [[ -n "$EXISTING_STORAGE_ACCOUNT" ]]
then
  # Use existing storage account name
  echo -e "\n\e[0;33mExisting storage account $EXISTING_STORAGE_ACCOUNT found.\e[0m"
  STORAGE_ACCOUNT_NAME=$EXISTING_STORAGE_ACCOUNT
  echo -e "\n\e[0;33mUsing existing storage account...\e[0m"
  echo -e "\e[1;34mAZURE_STORAGE_ACCOUNT\e[1;37m: \e[0;32m$AZURE_STORAGE_ACCOUNT\e[0m"
else
  # Generate unique name and create storage account for Terraform remote state
  RANDOM_STRING=$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)
  STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_PREFIX$RANDOM_STRING"
  echo -e "\n\e[0;33mCreating storage account...\e[0m"
  az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --kind StorageV2 --sku Standard_LRS
  echo -e "\e[1;34mSTORAGE_ACCOUNT_NAME\e[1;37m: \e[0;32m$STORAGE_ACCOUNT_NAME\e[0m"
fi

# Fetch storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --output tsv --query [0].value)
echo -e "\n\e[0;33mStorage account key:\e[0m"
echo -e "\e[1;34mkey1\e[1;37m: \e[0;32m$STORAGE_ACCOUNT_KEY\e[0m"

# Create storage container
echo -e "\n\e[0;33mCreating storage container...\e[0m"
echo -e "\e[1;34mCONTAINER_NAME\e[1;37m: \e[0;32m$CONTAINER_NAME\e[0m"
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Create service principal with contributor permissions
echo -e "\n\e[0;33mCreating service principal...\e[0m"
echo -e "\e[1;34mSERVICE_PRINCIPAL_NAME\e[1;37m: \e[0;32m$SERVICE_PRINCIPAL_NAME\e[0m"
SERVICE_PRINCIPAL_OUTPUT=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME)

# Export service principal data
SERVICE_PRINCIPAL_APPID=$(echo $SERVICE_PRINCIPAL_OUTPUT | jq -r '.appId')
SERVICE_PRINCIPAL_NAME=$(echo $SERVICE_PRINCIPAL_OUTPUT | jq -r '.name')
SERVICE_PRINCIPAL__PASSWORD=$(echo $SERVICE_PRINCIPAL_OUTPUT | jq -r '.password')
SERVICE_PRINCIPAL_TENANT=$(echo $SERVICE_PRINCIPAL_OUTPUT | jq -r '.tenant')
echo -e "\n\e[0;33mService principal object:\e[0m"
echo $SERVICE_PRINCIPAL_OUTPUT | jq

# Get current subscription id
echo -e "\n\e[0;33mChecking current subscription...\e[0m"
SUBSCRIPTION_NAME=$(az account list --output tsv --query [0].name)
SUBSCRIPTION_ID=$(az account list --output tsv --query [0].id)
echo -e "\n\e[0;33mCurrent subscription:\e[0m"
echo -e "\e[1;34mSUBSCRIPTION_NAME\e[1;37m: \e[0;32m$SUBSCRIPTION_NAME\e[0m"
echo -e "\e[1;34mSUBSCRIPTION_ID\e[1;37m:   \e[0;32m$SUBSCRIPTION_ID\e[0m"

# Print example terraform backend block
echo -e "\n\e[0;33mExample terraform provider.tf including azurerm backend: \e[0m"
setterm --foreground green
cat - <<EOF
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  version =  "~> 2.20"
}
EOF
setterm --foreground default

# Print output for GitHub secrets
echo -e "\n\e[0;33mEnvironment variables for GitHub secrets:\e[0m"
echo -e "\e[1;34mARM_ACCESS_KEY\e[1;37m:      \e[0;32m$STORAGE_ACCOUNT_KEY\e[0m"
echo -e "\e[1;34mARM_CLIENT_ID\e[1;37m:       \e[0;32m$SERVICE_PRINCIPAL_APPID\e[0m"
echo -e "\e[1;34mARM_CLIENT_SECRET\e[1;37m:   \e[0;32m$SERVICE_PRINCIPAL__PASSWORD\e[0m"
echo -e "\e[1;34mARM_SUBSCRIPTION_ID\e[1;37m: \e[0;32m$SUBSCRIPTION_ID\e[0m"
echo -e "\e[1;34mARM_TENANT_ID\e[1;37m:       \e[0;32m$SERVICE_PRINCIPAL_TENANT\e[0m\n"
