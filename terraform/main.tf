provider "azurerm" {
  features {}

  subscription_id = "73a0dc8f-18eb-4f75-a2d8-0393a6dedca7" # ✅ PROJET EFREI SUB1
  tenant_id       = "413600cf-bd4e-4c7c-8a61-69e73cddf731" # ✅ Tenant EFREI.NET
}

data "azurerm_client_config" "current" {}

# =======================================
# RESOURCE GROUP
# =======================================
resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
}

# =======================================
# STATIC IP (Module) Teleport
# =======================================
module "static_ip" {
  source         = "./modulesnew/static_ip"
  location       = var.location
  resource_group = var.resource_group
  # resource_group_name attribute removed as it is not expected here
}

# =======================================
# 2x AKS CLUSTERS (Modules)
# =======================================
module "aks_1" {
  source               = "./modulesnew/aks"
  location             = var.location
  # resource_group attribute removed as it is not expected here
  resource_group_name  = var.resource_group
  cluster_name         = "teleport-cluster-1"
  dns_prefix           = "teleport1"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
}

module "aks_2" {
  source               = "./modulesnew/aks"
  location             = var.location
  resource_group_name  = var.resource_group
  cluster_name         = "teleport-cluster-2"
  dns_prefix           = "teleport2"
}

# =======================================
# NETWORKING
# =======================================
resource "azurerm_virtual_network" "vnet" {
  name                = "clients-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "clients-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =======================================
# VM Ubuntu avec Keepalived
# =======================================
resource "azurerm_public_ip" "keepalived_ip" {
  name                = "ip-keepalived"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "keepalived_nic" {
  name                = "nic-keepalived"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "keepalived-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.keepalived_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "keepalived_vm" {
  name                  = "vm-keepalived"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.keepalived_nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "disk-keepalived"
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
  custom_data        = filebase64("${path.module}/cloud-init/ubuntu-keepalived.sh")
}

# =======================================
# CLIENT UBUNTU (Pour tester)
# =======================================
resource "azurerm_public_ip" "ubuntu_client_ip" {
  name                = "ip-ubuntu-client"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ubuntu_client_nic" {
  name                = "nic-ubuntu-client"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "client-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_client_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu_client" {
  name                  = "vm-ubuntu-client"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.ubuntu_client_nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "disk-ubuntu-client"
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
  custom_data        = filebase64("${path.module}/cloud-init/ubuntu-agent.sh")
}
