terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Ressource de test
resource "azurerm_resource_group" "myResourceGroup" {
  name     = "DEMO-PPL-10-demo-az-vcs"
  location = "eastus"
}

# 1. Reseau virtuel (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-cicd-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myResourceGroup.location
  resource_group_name = azurerm_resource_group.myResourceGroup.name
}

# 2. Sous-reseau (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.myResourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. Adresse IP Publique pour la future VM
resource "azurerm_public_ip" "pip" {
  name                = "pip-vm-demo"
  location            = azurerm_resource_group.myResourceGroup.location
  resource_group_name = azurerm_resource_group.myResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 4. Interface reseau (NIC) reliant le Subnet et l'IP Publique
resource "azurerm_network_interface" "nic" {
  name                = "nic-vm-demo"
  location            = azurerm_resource_group.myResourceGroup.location
  resource_group_name = azurerm_resource_group.myResourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}