# Create Azure Compute Gallery
resource "azurerm_resource_group" "gallery-resource-group" {
  name     = "rg-${var.workload}-gallery-${var.environment}-${var.location_short}-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_shared_image_gallery" "gallery" {
  name                = "gal${var.workload}${var.environment}${var.location_short}001"
  resource_group_name = azurerm_resource_group.gallery-resource-group.name
  location            = var.location
  description         = "Shared image gallery for Virtual Machine applications"
  tags                = var.tags
}

# Create storage account to store the installers
resource "azurerm_storage_account" "installer_storage" {
  name                     = "stginstallerdemo"
  resource_group_name      = azurerm_resource_group.gallery-resource-group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "installer_container" {
  name                  = "installers"
  storage_account_name  = azurerm_storage_account.installer_storage.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "sas_token" {
  connection_string = azurerm_storage_account.installer_storage.primary_connection_string
  container_name    = "installers"
  https_only        = true

  start  = time_static.today.rfc3339
  expiry = time_offset.tomorrow.rfc3339

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}

# Upload Java installer to storage account
resource "azurerm_storage_blob" "installer_blob" {
  name                   = "jdk-23_windows-x64_bin.msi"
  storage_account_name   = azurerm_storage_account.installer_storage.name
  storage_container_name = azurerm_storage_container.installer_container.name
  type                   = "Block"
  source                 = "installers/jdk-23_windows-x64_bin.msi"
}

# Create a gallery application for Java
resource "azurerm_gallery_application" "java" {
  name              = "java"
  description       = "java Installer"
  gallery_id        = azurerm_shared_image_gallery.gallery.id
  location          = var.java.location
  supported_os_type = var.java.supported_os_type
  tags              = var.tags
}

# Create a gallery application version for Java
resource "azurerm_gallery_application_version" "java23" {
  name                   = "23.0.0"
  gallery_application_id = azurerm_gallery_application.java.id
  location               = var.java.location
  package_file           = "jdk-23_windows-x64_bin.msi"
  tags                   = var.tags

  manage_action {
    //install = "rename java${each.key} CollectorInstaller64_5.0.3.965_Brenntag.msi && cmd /c msiexec /i CollectorInstaller64_5.0.3.965_Brenntag.msi /qn DEFGROUP=\"${each.key} - AZ - Servers\""
    install = "rename java23 jdk-23_windows-x64_bin.msi && cmd jdk-23_windows-x64_bin.msi /i /qn"
    remove  = "msiexec.exe /i jdk-23_windows-x64_bin.msi /qn"
  }

  source {
    media_link = "https://stginstallerdemo.blob.core.windows.net/installers/jdk-23_windows-x64_bin.msi?${data.azurerm_storage_account_blob_container_sas.sas_token.sas}"
  }

  dynamic "target_region" {
    for_each = var.java.target_regions
    content {
      exclude_from_latest    = target_region.value.exclude_from_latest
      name                   = target_region.value.location
      regional_replica_count = target_region.value.regional_replica_count
      storage_account_type   = target_region.value.storage_account_type
    }
  }
}

# Create a gallery application assignment for Java
resource "azurerm_virtual_machine_gallery_application_assignment" "example" {
  gallery_application_version_id = azurerm_gallery_application_version.java23.id
  virtual_machine_id             = azurerm_windows_virtual_machine.gallery_vm.id
}

// use a custom vm extension to install the Java application
resource "azurerm_virtual_machine_extension" "java" {
  name                 = "java"
  virtual_machine_id   = azurerm_windows_virtual_machine.gallery_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File install-java.ps1",
    "fileUris": [
                "https://stginstallerdemo.blob.core.windows.net/installers/jdk-23_windows-x64_bin.msi?${data.azurerm_storage_account_blob_container_sas.sas_token.sas}"
            ]
  }
  SETTINGS
}
