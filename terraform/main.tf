# ===============================
# PROVIDER + AUTHENTIFICATION
# ===============================
provider "azurerm" {
  features {}

  subscription_id = "73a0dc8f-18eb-4f75-a2d8-0393a6dedca7" # Ton abonnement Azure EFREI
  tenant_id       = "413600cf-bd4e-4c7c-8a61-69e73cddf731" # Le tenant EFREI
}

# Récupère les infos de l’utilisateur Azure actuel (ton object_id etc.)
data "azurerm_client_config" "current" {}

# # Assignment du rôle Cluster User sur l'AKS (si tu as le droit d'assigner)
# resource "azurerm_role_assignment" "aks_user_access" {
#   scope                = azurerm_kubernetes_cluster.teleport.id
#   role_definition_name = "Azure Kubernetes Service Cluster User Role"
#   principal_id         = data.azurerm_client_config.current.object_id
#   # depends_on           = [azurerm_kubernetes_cluster.teleport]
# }

# ===============================
# RESOURCE GROUP
# ===============================
resource "azurerm_resource_group" "main" {
  name     = var.resource_group       # Nom du groupe de ressources
  location = var.location              # Région (ex: francecentral)
}

# ===============================
# CLUSTER AKS (2 Nœuds)
# ===============================
# resource "azurerm_kubernetes_cluster" "teleport" {
#   name                = "aks-teleport"                 # Nom du cluster AKS
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   dns_prefix          = "teleportk8s"                  # Préfixe DNS public
#   sku_tier            = "Free"                         # Niveau gratuit

#   # Pool de nœuds par défaut
#   default_node_pool {
#     name       = "default"
#     node_count = 2                                     # 2 nœuds pour la redondance
#     vm_size    = "Standard_B2s"                        # Taille de VM économique
#   }

#   # Identité managée (gérée par Azure)
#   identity {
#     type = "SystemAssigned"
#   }

#   # Infos SSH pour accéder aux nœuds si besoin
#   linux_profile {
#     admin_username = "azureuser"

#     ssh_key {
#       key_data = file("~/.ssh/id_rsa.pub")
#     }
#   }

#   # Tags pratiques pour identifier l’environnement
#   tags = {
#     env  = "dev"
#     team = "efrei"
#   }
# }

# ------
resource "azurerm_kubernetes_cluster" "teleport" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name            = "agentpool"
    node_count      = var.agent_count
    vm_size         = "Standard_B2ms"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "efrei_teleport"
  }
}


# # ===============================
# # VM UBUNTU CLIENT (pour tester teleport)
# # ===============================
# resource "azurerm_linux_virtual_machine" "ubuntu_client" {
#   name                  = "teleport-ubuntu-client"
#   resource_group_name   = azurerm_resource_group.main.name
#   location              = var.location
#   size                  = "Standard_B1s"                                   # VM économique
#   admin_username        = "ubuntu"
#   network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]

#   disable_password_authentication = true

#   admin_ssh_key {
#     username   = "ubuntu"
#     public_key = file("/home/ubuntu/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     name                 = "ubuntu-client-os-disk"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#     disk_size_gb         = 30
#   }
  
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "22.04-lts"  # 🔧 Corrigé ici !
#     version   = "latest"
#   }


#   provision_vm_agent = true
#   custom_data        = filebase64("./clients/cloud-init/ubuntu-agent.sh")
# }
