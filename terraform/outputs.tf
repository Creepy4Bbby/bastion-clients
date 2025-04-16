output "aks_name" {
  value = azurerm_kubernetes_cluster.teleport.name
}

output "resource_group" {
  value = azurerm_resource_group.aks.name
}
