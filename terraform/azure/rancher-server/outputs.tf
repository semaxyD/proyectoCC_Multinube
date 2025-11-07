output "rancher_public_ip" {
  description = "Public IP address of Rancher server"
  value       = azurerm_public_ip.rancher_public_ip.ip_address
}

output "rancher_url" {
  description = "URL to access Rancher"
  value       = "https://${azurerm_public_ip.rancher_public_ip.ip_address}"
}

output "ssh_command" {
  description = "SSH command to connect to Rancher VM"
  value       = "ssh -i ssh_keys/rancher_key.pem ${var.admin_username}@${azurerm_public_ip.rancher_public_ip.ip_address}"
}

output "get_bootstrap_password_command" {
  description = "Command to retrieve Rancher bootstrap password"
  value       = "ssh -i ssh_keys/rancher_key.pem ${var.admin_username}@${azurerm_public_ip.rancher_public_ip.ip_address} 'sudo docker logs $(sudo docker ps -q -f name=rancher) 2>&1 | grep \"Bootstrap Password:\"'"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rancher_rg.name
}

output "vm_name" {
  description = "Name of the Rancher VM"
  value       = azurerm_linux_virtual_machine.rancher_vm.name
}
