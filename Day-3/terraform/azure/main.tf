# Cloud Trio Challenge — Day 3: Database Services
##################################################################
# Azure — one Flexible Server PostgreSQL instance, closed by default
##################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "eastus"
}

variable "db_admin_login" {
  default = "appadmin"
}

variable "db_admin_password" {
  description = "Administrator password for the Flexible Server"
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "db" {
  name     = "app-db-rg"
  location = var.location
}

# --- The instance: public access mode, closed until a firewall rule allows in ---
resource "azurerm_postgresql_flexible_server" "app" {
  name                = "app-postgres-flex"
  resource_group_name = azurerm_resource_group.db.name
  location            = azurerm_resource_group.db.location

  version = "16"
  sku_name = "B_Standard_B1ms"
  storage_mb = 32768

  administrator_login    = var.db_admin_login
  administrator_password = var.db_admin_password

  public_network_access_enabled = true

  backup_retention_days = 7
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.app.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# --- What gates access: same idea as the Day 2 NSG ---
# No firewall rule is defined here on purpose — add your own IP range
# below to open access, otherwise the server accepts no inbound traffic.
#
# resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_client" {
#   name             = "allow-my-ip"
#   server_id        = azurerm_postgresql_flexible_server.app.id
#   start_ip_address = "203.0.113.10" # tighten this to your own IP in real use
#   end_ip_address   = "203.0.113.10"
# }

output "db_fqdn" {
  value = azurerm_postgresql_flexible_server.app.fqdn
}
