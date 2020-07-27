resource "azurerm_resource_group" "storage_rg" {
  name     = "${var.env}-${var.app_name}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.env}${var.app_name}"
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}