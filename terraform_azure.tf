# Bloco que configura o Azure como provedor para trabalhar
provider "azurerm" {
    # version = "~>2.0"
    features {}
}

# Bloco de criação do Resource Group
resource "azurerm_resource_group" "tfwilson-rg" {
    name     = "RG-WILSON"
    location = "eastus"

    tags = {
        environment = "Terraform"
    }
}

# Bloco de criação da VNET
resource "azurerm_virtual_network" "tfwilson-vnet" {
    name                = "Vnet-WILSON"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.tfwilson-rg.name

    tags = {
        environment = "Terraform"
    }
}

# Bloco de criação da Subnet
resource "azurerm_subnet" "tfwilson-subnet" {
    name                 = "SUBNET-A"
    resource_group_name  = azurerm_resource_group.tfwilson-rg.name
    virtual_network_name = azurerm_virtual_network.tfwilson-vnet.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Bloco de criação do IP público
resource "azurerm_public_ip" "tfwilson-publicip" {
    name                         = "P-IP-WILSON"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.tfwilson-rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
    }
}

# Bloco de criação do NSG e criação de regra
resource "azurerm_network_security_group" "tfwilson-nsg" {
    name                = "NSG-WILSON"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.tfwilson-rg.name

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

    tags = {
        environment = "Terraform"
    }
}

# Bloco de criação de interface de rede
resource "azurerm_network_interface" "tfwilson-nic" {
    name                      = "NIC-WILSON"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.tfwilson-rg.name

    ip_configuration {
        name                          = "NicConfiguration"
        subnet_id                     = azurerm_subnet.tfwilson-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.tfwilson-publicip.id
    }

    tags = {
        environment = "Terraform"
    }
}

# Bloco que liga o NSG a interface de rede
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.tfwilson-nic.id
    network_security_group_id = azurerm_network_security_group.tfwilson-nsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "tfwilson-storage" {
    name                        = "diagwilsoncloud"
    resource_group_name         = azurerm_resource_group.tfwilson-rg.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform"
    }
}

# Bloco que cria a máquina virtual
resource "azurerm_linux_virtual_machine" "tfwilson-vm" {
    name                  = "srv-app1"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.tfwilson-rg.name
    network_interface_ids = [azurerm_network_interface.tfwilson-nic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "srv-app1-Os-Disk0"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "srv-app1"
    admin_username = "adminwilson"
    admin_password = "8@@nefFv!"
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.tfwilson-storage.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform"
    }
}
