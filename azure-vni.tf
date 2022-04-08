resource "azurerm_virtual_network" "vn" {
  name     = var.azure.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.azure.vnet.cidr]
}

resource "azurerm_route_table" "rt" {
  count = length(var.azure.vnet.subnets)
  name = "rt-${var.azure.vnet.subnets[count.index].name}"
  location = var.azure.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet" "subnet" {
  count = length(var.azure.vnet.subnets)
  name = var.azure.vnet.subnets[count.index].name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes = [var.azure.vnet.subnets[count.index].cidr]
}

resource "azurerm_subnet_network_security_group_association" "sgSubnetAssociation" {
  count = length(var.azure.vnet.subnets)
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_subnet_route_table_association" "rtSubnetAssociation" {
  count = length(var.azure.vnet.subnets)
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  route_table_id = azurerm_route_table.rt[count.index].id
}

#
# the following allows the network app to reach the Internet
#

resource "azurerm_public_ip" "ip-nat-gw-for-app-subnet" {
  name = "natGwIp"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.azure.rg.location
  allocation_method = "Static"
  sku                 = "Standard"
  tags = {
    createdBy = "Terraform"
  }
}

resource "azurerm_nat_gateway" "nat-gw-for-app-subnet" {
  name                = var.azure.vnet.nat_gateway.name
  location = var.azure.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "natGwPublicIpAssociation" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gw-for-app-subnet.id
  public_ip_address_id = azurerm_public_ip.ip-nat-gw-for-app-subnet.id
}

data "azurerm_subnet" "subnets-for-nat-gw" {
  depends_on = [azurerm_subnet.subnet]
  count = length(var.azure.vnet.nat_gateway.subnet_names)
  name                 = var.azure.vnet.nat_gateway.subnet_names[count.index]
  virtual_network_name = azurerm_virtual_network.vn.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_nat_gateway_association" "nat-for-subnets" {
  count = length(var.azure.vnet.nat_gateway.subnet_names)
  subnet_id      = data.azurerm_subnet.subnets-for-nat-gw[count.index].id
  nat_gateway_id = azurerm_nat_gateway.nat-gw-for-app-subnet.id
}


//resource "azurerm_subnet_nat_gateway_association" "nat-for-subnet-app" {
//  subnet_id      = azurerm_subnet.subnet[1].id
//  nat_gateway_id = azurerm_nat_gateway.nat-gw-for-app-subnet.id
//}
