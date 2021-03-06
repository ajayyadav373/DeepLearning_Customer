resource "azurerm_virtual_machine_extension" "downloadsolarwindagent" {
  name                 = "DownloadSolarWindAgent"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.pcloudbaseind1.name}"
  virtual_machine_name = "${azurerm_virtual_machine.SolarWindAgent.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.4"
  depends_on           = ["azurerm_virtual_machine.SolarWindAgent"]
  settings = <<RUNSTEPS
    {
	"commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Invoke-WebRequest -Uri https://rmm.softwareone.cloud/dms/FileDownload?customerID=107'&'softwareID=101 -OutFile C:/SolarWindAgnet.exe ; C:/SolarWindAgnet.exe \"/quiet" 
    }

RUNSTEPS
}

resource "azurerm_virtual_machine" "SolarWindAgent" {
  name                  = "${var.resource_group_name}SolarWindAgent"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.pcloudbaseind1.name}"
  network_interface_ids = ["${azurerm_network_interface.solarwind.id}"]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
storage_os_disk {
    name          = "${var.resource_group_name}-SolarWindAgentStorageOs"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.container.name}/${var.resource_group_name}-VM-OS.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }
  storage_data_disk {
    name          = "${var.resource_group_name}-SolarWindAgentStorageDisk"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.container.name}/${var.resource_group_name}-VM-DATA.vhd"
    disk_size_gb  = "4"
    create_option = "Empty"
    lun           = 0
  }
os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent = true
}
}
