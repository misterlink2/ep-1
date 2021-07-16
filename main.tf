terraform {
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.67.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "minecraft" {
  name     = "hashicraft"  
  location = "East US"
}

resource "azurerm_container_group" "minecraft" {
  name                = "minecraft"
  location            = azurerm_resource_group.minecraft.location
  resource_group_name = azurerm_resource_group.minecraft.name
  ip_address_type     = "public"
  dns_name_label      = "hashicraft"
  os_type             = "Linux"

  container {
    name   = "studio"
    image = "itzg/minecraft-server"
    cpu = "1"
    memory = "1"

    # Main minecraft port
    ports {
      port     = 25565
      protocol = "TCP"
    } 

    environment_variables = {
      JAVA_MEMORY="1G",
      MINECRAFT_MOTD="HashiCraft",
      RESOURCE_PACK="https://github.com/HashiCraft/terraform_minecraft_azure_containers/releases/download/files/KawaiiWorld1.12.zip",
      WORLD_BACKUP="https://github.com/HashiCraft/terraform_minecraft_azure_containers/releases/download/files/example_world.tar.gz",
      WHITELIST_ENABLED=true,
      RCON_ENABLED=true,
      RCON_PASSWORD=random_password.password.result
    }
  }
}

output "fqdn" {
  value = azurerm_container_group.minecraft.fqdn
  sensitive = true
}

output "rcon_password" {
  value = random_password.password.result
  sensitive = true
}
