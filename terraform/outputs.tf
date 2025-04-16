output "teleport_ip" {
  value = module.static_ip.teleport_ip
}
output "aks_name" {
  value = azurerm_kubernetes_cluster.teleport.name
}

output "resource_group" {
  value = azurerm_resource_group.aks.name
}








