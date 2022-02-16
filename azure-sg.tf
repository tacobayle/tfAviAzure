resource "azurerm_network_security_group" "sg" {
  name = var.azure.sg.name
  location = var.azure.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "sgRule" {
//  depends_on = [azurerm_network_security_group.sg]
  count = length(var.azure.sg.rules)
  name = var.azure.sg.rules[count.index].name
  priority = "10${count.index}"
  direction = "Inbound"
  access = "Allow"
  protocol = var.azure.sg.rules[count.index].protocol
  source_port_range = "*"
  destination_port_range = var.azure.sg.rules[count.index].dest_port
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.sg.name
}
