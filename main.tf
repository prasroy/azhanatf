provider "azurerm" {
    version = "=1.28.0"
}
resource "azurerm_resource_group" "hanatfrg" {
    name = "${var.rgname}"
    location = "${var.location}"
tags {environment = "Demo"}
  }
resource "azurerm_network_security_group" "hanatfnsg" {
    name = "nsg"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
}
resource "azurerm_network_security_rule" "hanatfnsg" {
      name                        = "SSH"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = "${azurerm_resource_group.hanatfrg.name}"
      network_security_group_name = "${azurerm_network_security_group.hanatfnsg.name}"
}
resource "azurerm_virtual_network" "hanatfvnet" {
    name = "vnet-sap"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    location = "${azurerm_resource_group.hanatfrg.location}"
    address_space = "${var.vnetprefix}"
    }
resource "azurerm_subnet" "hanatfsubnet" {
        name = "subnet-hana"
        resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
        virtual_network_name = "${azurerm_virtual_network.hanatfvnet.name}"
        address_prefix = "${var.subnetprefix}"
        network_security_group_id = "${azurerm_network_security_group.hanatfnsg.id}"
}
resource "azurerm_public_ip" "hanatfpip" {
    name = "${var.SID}.hanapip"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    allocation_method = "Dynamic"
}
resource "azurerm_network_interface" "hanatfnic" {
    name = "${var.SID}.hananic"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    ip_configuration {
        name = "ipconfig00"
        subnet_id = "${azurerm_subnet.hanatfsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.hanatfpip.id}"
        }
        enable_accelerated_networking = 1
}
module "create_vm" {
    source = "modules/create_vm"
    vmname = "${local.vmname}"
    location = "${azurerm_resource_group.hanatfrg.location}"
    rgname = "${azurerm_resource_group.hanatfrg.name}"
    network_interface_ids = ["${azurerm_network_interface.hanatfnic.id}"]
    vmsize = "${var.vmsize}"
    adminuser = "${var.adminuser}"
    adminpwd = "${var.adminpwd}"
    sid = "${var.SID}"
}