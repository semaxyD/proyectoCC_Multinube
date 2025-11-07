terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rancher_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "rancher_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  tags                = var.tags
}

# Subnet
resource "azurerm_subnet" "rancher_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rancher_rg.name
  virtual_network_name = azurerm_virtual_network.rancher_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "rancher_public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Security Group
resource "azurerm_network_security_group" "rancher_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  tags                = var.tags

  # Allow SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Kubernetes API
  security_rule {
    name                       = "K8S-API"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "rancher_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rancher_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rancher_public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "rancher_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.rancher_nic.id
  network_security_group_id = azurerm_network_security_group.rancher_nsg.id
}

# SSH Key
resource "tls_private_key" "rancher_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "rancher_private_key" {
  content         = tls_private_key.rancher_ssh.private_key_pem
  filename        = "${path.module}/../../../ssh_keys/rancher_key.pem"
  file_permission = "0600"
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "rancher_vm" {
  name                = "${var.prefix}-vm"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.rancher_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.rancher_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 50
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    rancher_version = var.rancher_version
  }))

  # Ensure the VM has time to initialize
  provisioner "local-exec" {
    command = "echo 'Waiting for Rancher VM to initialize...'"
  }
}

# Optional: Wait for Rancher to be ready
resource "null_resource" "wait_for_rancher" {
  depends_on = [azurerm_linux_virtual_machine.rancher_vm]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Rancher to be accessible..."
      for i in {1..30}; do
        if curl -k -s -o /dev/null -w "%%{http_code}" https://${azurerm_public_ip.rancher_public_ip.ip_address} | grep -q "200\|301\|302"; then
          echo "Rancher is ready!"
          exit 0
        fi
        echo "Attempt $i: Rancher not ready yet, waiting 30s..."
        sleep 30
      done
      echo "Warning: Rancher may still be initializing. Check manually."
    EOT
  }
}
