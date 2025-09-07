output "dc01_public_ip" {
  value = azurerm_public_ip.dc01_pip.ip_address
}

output "ws01_public_ip" {
  value = azurerm_public_ip.ws01_pip.ip_address
}
