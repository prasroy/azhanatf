resource "azurerm_virtual_machine" "hanatfvm" {
    
    name = "${var.vmname}"
    location = "${var.location}"
    resource_group_name = "${var.rgname}"
    network_interface_ids = ["${var.network_interface_ids}"]
    vm_size = "${var.vmsize}"
        storage_image_reference {
            publisher = "SUSE"
            offer = "SLES-SAP"
            sku = "12-SP4"
            version = "2019.030.06"
        }
        storage_os_disk {
            name = "${var.vmname}-osdisk"
            caching = "ReadWrite"
            create_option = "FromImage"
        }
        os_profile {
            computer_name = "${var.vmname}"
            admin_username = "${var.adminuser}"
            admin_password = "${var.adminpwd}"
        }
        os_profile_linux_config{
            disable_password_authentication = "false"
        }
        storage_data_log_disk { 
            name = "${var.vmname}-datadisk1"
            caching = "None"
            create_option = "Empty"
            managed_disk_type = "Premium_LRS"
            disk_size_gb = 512
            lun = 0
        }
        storage_data_log_disk { 
            name = "${var.vmname}-datadisk2"
            caching = "None"
            create_option = "Empty"
            managed_disk_type = "Premium_LRS"
            disk_size_gb = 512
            lun = 1
        }
        storage_hana_shared_disk { 
            name = "${var.vmname}-datadisk3"
            caching = "ReadOnly"
            create_option = "Empty"
            managed_disk_type = "Standard_LRS"
            disk_size_gb = 256
            lun = 2
        }
        storage_root_disk { 
            name = "${var.vmname}-datadisk4"
            caching = "None"
            create_option = "Empty"
            managed_disk_type = "Standard_LRS"
            disk_size_gb = 64
            lun = 3
        }
        storage_usr_sap_disk { 
            name = "${var.vmname}-datadisk5"
            caching = "None"
            create_option = "Empty"
            managed_disk_type = "Standard_LRS"
            disk_size_gb = 64
            lun = 4
        }
        storage_backup_disk { 
            name = "${var.vmname}-datadisk6"
            caching = "None"
            create_option = "Empty"
            managed_disk_type = "Standard_LRS"
            disk_size_gb = 256
            lun = 5
        }
    provisioner "file" {
    source = "modules/create_vm/filesystem.sh"
    destination = "/tmp/filesystem.sh"
    connection {
        type = "ssh"
        user = "${var.adminuser}"
        password = "${var.adminpwd}"
               }
    }
}
resource "azurerm_virtual_machine_extension" "hanatfvmext" {

    name                 = "${var.vmname}"
    location             = "${var.location}"
    resource_group_name  = "${var.rgname}"
    virtual_machine_name = "${var.vmname}"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    depends_on = ["azurerm_virtual_machine.hanatfvm"]
    settings = <<SETTINGS
    {
      "commandToExecute" : "[ chmod 755 /tmp/filesystem.sh ; bash /tmp/filesystem.sh ${var.sid} DEMO >> /tmp/filesystem.out ]"
    }
    SETTINGS
}