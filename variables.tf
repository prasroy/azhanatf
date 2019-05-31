variable "vmname" {
    description = "Provide the vmname for your HANA Box"
}
variable "bastionvm" {
    description = "Provide the vmname for your windows bastion host"
}
variable "rgname" {
    description = "Target resource group name"
}
variable "location" {
    description = "Location for the resources"
    default = "WestEurope"
}
variable "vnetprefix" {
    description = "Address prefix for the VNET"
    default = ["10.0.0.0/24"]
}
variable "hanasubnetprefix" {
    description = "Address prefix for subnet"
    default  = "10.0.0.0/28"
}
variable "mgmtsubnetprefix" {
    description = "Address prefix for subnet"
    default  = "10.1.0.0/28"
}
variable "adminuser" {
    type = "string"
    description = "HANA VM Admin user"
    default = "azureuser"
}
variable "adminpwd" {
    description = "HANA VM Admin password"
}
variable "vmsize" {
    description  = "Size of the VM to be created for HANA Database"
    default = "Standard_E16s_v3"
}
variable "bastionvmsize" {
    description  = "Size of the Bastion VM to be created for Management purpose"
    default = "Standard_D2_v2"
}
variable "bastionadminuser" {
    type = "string"
    description = "HANA VM Admin user"
    default = "azureuser"
}
variable "bastionadminpwd" {
    description = "HANA VM Admin password"
}