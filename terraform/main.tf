provider "azurerm" {
  features {}

  subscription_id                  = "73a0dc8f-18eb-4f75-a2d8-0393a6dedca7" # ✅ PROJET EFREI SUB1
  tenant_id                        = "413600cf-bd4e-4c7c-8a61-69e73cddf731" # ✅ Tenant EFREI.NET
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "aks" {
  name     = "rg-teleport-efrei"
  location = var.location
}

module "static_ip" {
  source         = "./modulesnew"
  location       = var.location
  resource_group = var.resource_group
}
# IP Téléport pour DNS :
# module.static_ip.teleport_ip

resource "azurerm_kubernetes_cluster" "teleport" {
  name                = "aks-teleport"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "teleportk8s"
  sku_tier            = "Free"

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
    team = "efrei"
    env  = "dev"
  }
}

resource "azurerm_role_assignment" "aks_user_access" {
  scope                = azurerm_kubernetes_cluster.teleport.id
  role_definition_name = "Azure Kubernetes Service Cluster User"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_kubernetes_cluster.teleport]
}

# ==============================
#           NETWORKING
# ==============================
resource "azurerm_virtual_network" "clients_vnet" {
  name                = "clients-vnet"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "clients_subnet" {
  name                 = "clients-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.clients_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ==============================
#        VM UBUNTU CLIENT
# ==============================
resource "azurerm_public_ip" "ubuntu_public_ip" {
  name                = "ubuntu-client-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "ubuntu-client-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ubuntu-client-ipconfig"
    subnet_id                     = azurerm_subnet.clients_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu_client" {
  name                  = "teleport-ubuntu-client"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "ubuntu-client-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provision_vm_agent = true

  custom_data = filebase64("${path.module}/cloud-init/ubuntu-agent.sh")
}

# ==============================
#        VM WINDOWS AD
# ==============================
resource "azurerm_public_ip" "ad_public_ip" {
  name                = "ad-server-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ad_nic" {
  name                = "ad-server-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ad-ipconfig"
    subnet_id                     = azurerm_subnet.clients_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ad_public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "ad_server" {
  name                  = "ad-server"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "SuperSecurePassword123!"
  network_interface_ids = [azurerm_network_interface.ad_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  provision_vm_agent = true

  custom_data = filebase64("${path.module}/cloud-init/ad-init.ps1")
}
