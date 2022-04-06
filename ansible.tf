resource "null_resource" "ansible" {
  depends_on = [azurerm_virtual_machine.jump]

  connection {
    host = azurerm_public_ip.jumpPublicIp.ip_address
    type = "ssh"
    agent = false
    user = var.jump.username
    private_key = file(var.ssh_key.private)
  }

  provisioner "file" {
    source = var.ssh_key.private
    destination = "/home/${var.jump.username}/.ssh/${basename(var.ssh_key.private)}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.ssh_key.private)}",
      "mkdir -p ansible",
      "cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag}; cd ${split("/", var.ansible.aviConfigureUrl)[4]}",
      "ansible-playbook azure.yml --extra-vars '{\"avi_username\": ${jsonencode(var.avi_username)}, \"avi_password\": ${jsonencode(var.avi_password)}, \"avi_old_password\": ${jsonencode(var.avi_old_password)}, \"avi_version\": ${jsonencode(var.controller.aviVersion)}, \"controllerPrivateIps\": ${jsonencode(azurerm_network_interface.nicController.*.private_ip_address)}, \"controller\": ${jsonencode(var.controller)}, \"vnet_id\": ${jsonencode(azurerm_virtual_network.vn.id)}, \"subnet_mgmt_name\": ${jsonencode(var.azure.vnet.subnets[0].name)}, \"azure\": ${jsonencode(var.azure)}, \"azure_location\": ${jsonencode(replace(lower(var.azure.rg.location), " ", ""))}, \"azure_subscription_id\": ${jsonencode(var.azure_subscription_id)}, \"subnet_vip_name\": ${jsonencode(var.azure.vnet.subnets[2].name)}, \"subnet_vip_cidr\": ${jsonencode(var.azure.vnet.subnets[2].cidr)}, \"avi_backend_servers_azure\": ${jsonencode(azurerm_network_interface.nicBackend.*.private_ip_address)}, \"scale_set_name\": ${jsonencode(var.scaleset.name)}}'"
    ]
  }
}