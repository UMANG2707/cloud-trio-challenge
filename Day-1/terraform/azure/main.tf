##################################################################
# Cloud Trio Challenge — Day 1: IAM
# Azure — let one VM read one Storage Account, nothing else
##################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "eastus"
}

variable "storage_account_name" {
  default = "myappdatastorage" # base name — a random suffix is appended to keep it globally unique
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used to log into the VM"
  default     = "~/.ssh/id_rsa.pub"
}

# Storage account names must be globally unique, lowercase, no dashes,
# so a random suffix is appended automatically instead of requiring a manual edit.
resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "app" {
  name     = "app-rg"
  location = var.location
}

# --- The room: one Storage Account ---
resource "azurerm_storage_account" "app_data" {
  name                     = "${var.storage_account_name}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.app.name
  location                 = azurerm_resource_group.app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "app" {
  name                = "app-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "app" {
  name                = "app-nic"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# --- The badge: a managed identity, created automatically with the VM ---
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                  = "app-vm"
  resource_group_name   = azurerm_resource_group.app.name
  location              = azurerm_resource_group.app.location
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.app.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# --- The rule: read-only, scoped to THIS storage account only ---
# (not the resource group — that would leak access to every other
# storage account inside it)
resource "azurerm_role_assignment" "read_one_storage_account" {
  scope                = azurerm_storage_account.app_data.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.app_vm.identity[0].principal_id
}

output "vm_identity_principal_id" {
  value = azurerm_linux_virtual_machine.app_vm.identity[0].principal_id
}

output "storage_account_name" {
  value = azurerm_storage_account.app_data.name
}
