variable "SID" {
    description = "SAP System ID"
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
    default = ["172.16.0.0/24"]
}
variable "subnetprefix" {
    description = "Address prefix for subnet"
    default  = "172.16.0.0/24"
}
variable "adminuser" {
    description = "OS Admin user"
}
variable "adminpwd" {
    description = "OS Admin password"
}
variable "vmsize" {
    description  = "Size of the VM to be created"
    default = "Standard_E4s_v3"
}