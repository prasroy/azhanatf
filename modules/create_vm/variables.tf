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
variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  default     = "true"
}
variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default     = "Standard_LRS"
}