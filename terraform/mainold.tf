terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3"
}

provider "azurerm" {
  features {}

  subscription_id = "73a0dc8f-18eb-4f75-a2d8-0393a6dedca7" # A voir quand on changera de subscription suivant les couts
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-teleport-efrei"
  location = "francecentral"
}

resource "azurerm_kubernetes_cluster" "teleport" {
  name                = "aks-teleport"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "teleportk8s"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    env = "dev"
    team = "efrei"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.teleport.kube_config_raw
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.teleport.kube_config[0].client_certificate
  sensitive = true
}
