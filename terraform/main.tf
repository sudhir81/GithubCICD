# -------------------------------
# Provider
# -------------------------------
provider "azurerm" {
  features {}
}

# -------------------------------
# Resource Group
# -------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-ansible-demo"
  location = var.location
}

# -------------------------------
# Virtual Network
# -------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ansible"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# -------------------------------
# Subnet
# -------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -------------------------------
# Network Security Group
# -------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ansible"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# NSG Rules
resource "azurerm_network_security_rule" "winrm" {
  name                        = "Allow-WinRM"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "Allow-RDP"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "icmp" {
  name                        = "Allow-ICMP"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

# -------------------------------
# Public IPs
# -------------------------------
resource "azurerm_public_ip" "dc01_pip" {
  name                = "pip-dc01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "ws01_pip" {
  name                = "pip-ws01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -------------------------------
# Network Interfaces
# -------------------------------
resource "azurerm_network_interface" "dc01_nic" {
  name                = "nic-dc01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dc01_pip.id
  }
}

resource "azurerm_network_interface" "ws01_nic" {
  name                = "nic-ws01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ws01_pip.id
  }
}

# Associate NSG with NICs
resource "azurerm_network_interface_security_group_association" "dc01_nic_nsg" {
  network_interface_id      = azurerm_network_interface.dc01_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "ws01_nic_nsg" {
  network_interface_id      = azurerm_network_interface.ws01_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -------------------------------
# Windows VMs
# -------------------------------
resource "azurerm_windows_virtual_machine" "dc01" {
  name                  = "DC01"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.dc01_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "ws01" {
  name                  = "WS01"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.ws01_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# -------------------------------
# WinRM Extensions
# -------------------------------
resource "azurerm_virtual_machine_extension" "dc01_winrm_ext" {
  name                 = "EnableWinRM"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"
    Set-Item WSMan:\\localhost\\Service\\AllowUnencrypted -Value True;
    Set-Item WSMan:\\localhost\\Service\\Auth\\Basic -Value True;
    Restart-Service WinRM -Force
  \""
}
SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.dc01
  ]
}

resource "azurerm_virtual_machine_extension" "ws01_winrm_ext" {
  name                 = "EnableWinRM"
  virtual_machine_id   = azurerm_windows_virtual_machine.ws01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"
    Set-Item WSMan:\\localhost\\Service\\AllowUnencrypted -Value True;
    Set-Item WSMan:\\localhost\\Service\\Auth\\Basic -Value True;
    Restart-Service WinRM -Force
  \""
}
SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.ws01
  ]
}
