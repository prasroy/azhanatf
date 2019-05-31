provider "azurerm" {
    version = "=1.28.0"
}
resource "azurerm_resource_group" "hanatfrg" {
    name = "${var.rgname}"
    location = "${var.location}"
tags {environment = "Demo"}
}
resource "azurerm_network_security_group" "hanatfnsg" {
    name = "hana-nsg"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    tags = {
          environment = "Demo"
    }
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
resource "azurerm_network_security_rule" "hanatfnsg1" {
      name                        = "HANA"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "1024-65535"
      source_address_prefix       = "${var.mgmtsubnetprefix}"
      destination_address_prefix  = "*"
      resource_group_name         = "${azurerm_resource_group.hanatfrg.name}"
      network_security_group_name = "${azurerm_network_security_group.hanatfnsg.name}"
}
resource "azurerm_virtual_network" "hanatfvnet" {
    name = "vnet-sap"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    location = "${azurerm_resource_group.hanatfrg.location}"
    address_space = "${var.vnetprefix}"
    tags = {
          environment = "Demo"
    }
}
resource "azurerm_network_security_group" "mgmttfnsg" {
    name = "mgmt-nsg"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    tags = {
          environment = "Demo"
    }
}
resource "azurerm_network_security_rule" "mgmttfnsg" {
      name                        = "RDP"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "3389"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = "${azurerm_resource_group.hanatfrg.name}"
      network_security_group_name = "${azurerm_network_security_group.mgmttfnsg.name}"
}
resource "azurerm_network_security_rule" "mgmttfnsg1" {
      name                        = "SSH"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = "${azurerm_resource_group.hanatfrg.name}"
      network_security_group_name = "${azurerm_network_security_group.mgmttfnsg.name}"
}
resource "azurerm_subnet" "hanatfsubnet" {
        name = "subnet-hana"
        resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
        virtual_network_name = "${azurerm_virtual_network.hanatfvnet.name}"
        address_prefix = "${var.hanasubnetprefix}"
        network_security_group_id = "${azurerm_network_security_group.hanatfnsg.id}"
}
resource "azurerm_subnet" "mgmtsubnet" {
        name = "subnet-mgmt"
        resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
        virtual_network_name = "${azurerm_virtual_network.hanatfvnet.name}"
        address_prefix = "${var.mgmtsubnetprefix}"
        network_security_group_id = "${azurerm_network_security_group.mgmttfnsg.id}"
}
resource "azurerm_public_ip" "hanatfpip" {
    name = "${var.vmname}.pip"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    allocation_method = "Dynamic"
    sku = "basic"
    domain_name_label = "${var.vmname}"
    tags = {
          environment = "Demo"
    }
}
resource "azurerm_public_ip" "mgmttfpip" {
    name = "${var.bastionvm}.pip"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    allocation_method = "Dynamic"
    sku = "basic"
    domain_name_label = "${var.bastionvm}"
    tags = {
          environment = "Demo"
    }
}
resource "azurerm_network_interface" "hanatfnic" {
    name = "${var.vmname}.nic"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    ip_configuration {
        name = "ipconfig00"
        subnet_id = "${azurerm_subnet.hanatfsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.hanatfpip.id}"
        }
        enable_accelerated_networking = 1
        tags = {
          environment = "Demo"
    }
}
resource "azurerm_network_interface" "bastionftnic" {
    name = "${var.bastionvm}.nic"
    location = "${azurerm_resource_group.hanatfrg.location}"
    resource_group_name = "${azurerm_resource_group.hanatfrg.name}"
    ip_configuration {
        name = "ipconfig05"
        subnet_id = "${azurerm_subnet.mgmtsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.mgmttfpip.id}"
        }
        enable_accelerated_networking = 0
        tags = {
          environment = "Demo"
    }
}
module "create_vm" {
    source = "modules/create_vm"
    vmname = "${var.vmname}"
    location = "${azurerm_resource_group.hanatfrg.location}"
    rgname = "${azurerm_resource_group.hanatfrg.name}"
    network_interface_ids = ["${azurerm_network_interface.hanatfnic.id}"]
    vmsize = "${var.vmsize}"
    adminuser = "${var.adminuser}"
    adminpwd = "${var.adminpwd}"
}
module "create_bastion" {
    source = "modules/create_bastion"
    bastionvm = "${var.bastionvm}"
    location = "${azurerm_resource_group.hanatfrg.location}"
    rgname = "${azurerm_resource_group.hanatfrg.name}"
    bastion_network_interface_ids = ["${azurerm_network_interface.bastionftnic.id}"]
    bastionvmsize = "${var.bastionvmsize}"
    bastionadminuser = "${var.bastionadminuser}"
    bastionadminpwd = "${var.bastionadminpwd}"
}