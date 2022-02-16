resource "azurerm_resource_group" "rg" {
  name     = var.azure.rg.name
  location = var.azure.rg.location
}
