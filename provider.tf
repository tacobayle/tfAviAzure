provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      version = "2.95.0"
    }
  }
}