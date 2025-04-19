output "kube_config" {
  description = "Fichier kubeconfig pour se connecter à AKS"
  value       = azurerm_kubernetes_cluster.teleport.kube_config_raw
  sensitive   = true
}

output "aks_name" {
  description = "Nom du cluster AKS"
  value       = azurerm_kubernetes_cluster.teleport.name
}

output "resource_group" {
  description = "Nom du resource group"
  value       = azurerm_resource_group.main.name
}

output "ubuntu_public_ip" {
  description = "Adresse IP publique de la VM Ubuntu"
  value       = azurerm_public_ip.ubuntu_public_ip.ip_address
}
# ------

output "resource_group_name" {
  value = azurerm_resource_group.teleport.name
}

output "client_key" {
  value = azurerm_kubernetes_cluster.teleport.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.teleport.kube_config.0.username
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.teleport.kube_config_raw
  sensitive = true
}




# -----