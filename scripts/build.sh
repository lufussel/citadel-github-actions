#! /bin/bash

# Input variables
resource_group_name=citadeldemo-tfstate-rg
storage_account_name=citadeldemotfstatestg #note: must be unique
container_name=tfstate
location=uksouth
service_principal_name=citadeldemo-sp

# Create storage account for Terraform remote state
echo -e "\e[0;33mCreating storage account...\e[0m"
az group create --name $resource_group_name --location $location
az storage account create --name $storage_account_name --resource-group $resource_group_name --kind StorageV2 --sku Standard_LRS
az storage container create --name $container_name --account-name $storage_account_name
storage_account_key=$(az storage account keys list --account-name $storage_account_name --output tsv --query [0].value)
echo -e "\n\e[0;33mStorage account key:\e[0m"
echo -e "\e[1;34mkey1\e[1;37m: \e[0;32m$storage_account_key\e[0m"


# Create service principal with Contributor permissions
echo -e "\n\e[0;33mCreating service principal..."
service_principal_output=$(az ad sp create-for-rbac --name $service_principal_name)
service_principal_app_id=$(echo $service_principal_output | jq -r '.appId')
service_principal_name=$(echo $service_principal_output | jq -r '.name')
service_principal_password=$(echo $service_principal_output | jq -r '.password')
service_principal_tenant=$(echo $service_principal_output | jq -r '.tenant')
echo -e "\n\e[0;33mService principal object:\e[0m"
echo $service_principal_output | jq

# Get current subscription id
echo -e "\n\e[0;33mChecking current subscription...\e[0m"
subscription_name=$(az account list --output tsv --query [0].name)
subscription_id=$(az account list --output tsv --query [0].id)
echo -e "\e[0;33mCurrent subscription:\e[0m"
echo -e "\e[1;34msubscriptionName\e[1;37m: \e[0;32m$subscription_name\e[0m"
echo -e "\e[1;34msubscriptionId\e[1;37m:   \e[0;32m$subscription_id\e[0m"

# Print output for GitHub secrets
echo -e "\n\e[0;33mEnvironment variables for GitHub secrets:\e[0m"
echo -e "\e[1;34mARM_ACCESS_KEY\e[1;37m:      \e[0;32m$storage_account_key\e[0m"
echo -e "\e[1;34mARM_CLIENT_ID\e[1;37m:       \e[0;32m$service_principal_app_id\e[0m"
echo -e "\e[1;34mARM_CLIENT_SECRET\e[1;37m:   \e[0;32m$service_principal_password\e[0m"
echo -e "\e[1;34mARM_SUBSCRIPTION_ID\e[1;37m: \e[0;32m$subscription_id\e[0m"
echo -e "\e[1;34mARM_TENANT_ID\e[1;37m:       \e[0;32m$service_principal_tenant\e[0m\n"