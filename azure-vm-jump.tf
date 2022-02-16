resource "azurerm_public_ip" "jumpPublicIp" {
  name = "jumpPublicIp"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.azure.rg.location
  sku                 = "Standard"
  allocation_method = "Static"
  tags = {
    createdBy = "Terraform"
  }
}

resource "azurerm_network_interface" "nicJump" {
  depends_on = [azurerm_subnet_network_security_group_association.sgSubnetAssociation, azurerm_subnet_route_table_association.rtSubnetAssociation]
  name = "nic-jump"
  location = var.azure.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.0.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpPublicIp.id
  }
  tags = {
    createdBy = "Terraform"
  }
}

data "template_file" "jump" {
  template = file(var.jump.userdata)
  vars = {
    avisdkVersion = var.jump.avisdkVersion
    ansibleVersion = var.ansible.version
    ansiblePrefixGroup = var.ansible.prefixGroup
    privateKey = var.ssh_key.private
    username = var.jump.username
    rg = var.azure.rg.name
    azure_client_id = var.azure_client_id_ro
    azure_client_secret = var.azure_client_secret_ro
    azure_subscription_id = var.azure_subscription_id
    azure_tenant_id = var.azure_tenant_id
  }
}

resource "azurerm_virtual_machine" "jump" {
  depends_on = [azurerm_network_interface.nicJump, azurerm_virtual_machine.controller]
  name = var.jump.hostname
  location = var.azure.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size = var.jump.type
  network_interface_ids = [
    azurerm_network_interface.nicJump.id]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = var.jump.publisher
    offer = var.jump.offer
    sku = var.jump.sku
    version = "latest"
  }

  storage_os_disk {
    name = "${var.jump.hostname}_ssd"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }


  os_profile {
    computer_name = var.jump.hostname
    admin_username = var.jump.username
    custom_data = data.template_file.jump.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.jump.username}/.ssh/authorized_keys"
      key_data = file(var.ssh_key.public)
    }
  }

  tags = {
    createdBy = "Terraform"
    group = "jump"
  }

  connection {
    host = azurerm_public_ip.jumpPublicIp.ip_address
    type = "ssh"
    agent = false
    user = "ubuntu"
    private_key = file(var.ssh_key.private)
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
