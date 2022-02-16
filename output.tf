
output "jump_public_ip" {
  value = azurerm_public_ip.jumpPublicIp.ip_address
}

output "avi_controlle_public_ip" {
  value = azurerm_public_ip.controllerPublicIp.ip_address
}

output "destroy_command" {
  value = "ssh -o StrictHostKeyChecking=no -i ${var.ssh_key.private} -t ubuntu@${azurerm_public_ip.jumpPublicIp.ip_address} 'git clone ${var.ansible.aviPbAbsentUrl} --branch ${var.ansible.aviPbAbsentTag}; ansible-playbook ${basename(var.ansible.aviPbAbsentUrl)}/local.yml --extra-vars @${var.controller.aviCredsJsonFile}'; sleep 5 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
