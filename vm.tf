resource "azurerm_virtual_network" "gallery_vnet" {
  name                = "gallery-vnet"
  resource_group_name = azurerm_resource_group.gallery-resource-group.name
  location            = azurerm_resource_group.gallery-resource-group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "gallery_subnet" {
  name                 = "gallery-subnet"
  resource_group_name  = azurerm_resource_group.gallery-resource-group.name
  virtual_network_name = azurerm_virtual_network.gallery_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}


// create the nic for the Windows VM
resource "azurerm_network_interface" "gallery_nic" {
  name                = "gallery-nic"
  resource_group_name = azurerm_resource_group.gallery-resource-group.name
  location            = azurerm_resource_group.gallery-resource-group.location

  ip_configuration {
    name                          = "gallery-ipconfig"
    subnet_id                     = azurerm_subnet.gallery_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

// create a Windows VM that uses a public image and with remote access using Bastion
resource "azurerm_windows_virtual_machine" "gallery_vm" {
  name                  = "gallery-vm"
  resource_group_name   = azurerm_resource_group.gallery-resource-group.name
  location              = azurerm_resource_group.gallery-resource-group.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "<your-password>"
  network_interface_ids = [azurerm_network_interface.gallery_nic.id]

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
  provision_vm_agent = true

  depends_on = [azurerm_network_interface.gallery_nic]
}