resource "azurerm_public_ip" "teleport_static_ip" {
  name                = "teleport-static-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "teleport_ip" {
  value = azurerm_public_ip.teleport_static_ip.ip_address
}
