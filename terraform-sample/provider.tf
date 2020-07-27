terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "citadeldemotfstatestg"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = "= 2.0.0"
  features {}
}
