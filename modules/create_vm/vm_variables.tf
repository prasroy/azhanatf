variable "vmname" {
    description = "Variable name"
}
variable "rgname" {
    description = "Target resource group name"
}
variable "location" {
    description = "Location for the resources"
 }
variable "vmsize" {
    description = "VM size"
}
variable "network_interface_ids" {
    type = "list"
    description = "NIC ID"
    }
variable "adminuser" {
    description = "OS Admin user"
}
variable "adminpwd" {
    description = "OS Admin password"
}
variable "sid" {
    description = "SAP System ID"
}