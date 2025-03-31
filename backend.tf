terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "confitechtfstateaccount"
    container_name       = "tfstate"
    key                  = "vm.tfstate"
  }
}