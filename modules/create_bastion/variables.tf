variable "bastionvm" {
    description = "Provide bastion VM name"
}
variable "rgname" {
    description = "Target resource group name"
}
variable "location" {
    description = "Location for the resources"
 }
variable "bastionvmsize" {
    description = "VM size"
}
variable "bastion_network_interface_ids" {
    type ="list"
    description = "NIC ID of bastion VM"
    }
variable "bastionadminuser" {
    description = "OS Admin user"
}
variable "bastionadminpwd" {
    description = "OS Admin password"
}
variable "delete_os_disk_on_termination" {
  description = "Delete datadisk when machine is terminated"
  default     = "true"
}
variable "delete_data_disk_on_termination" {
  description = "Delete datadisk when machine is terminated"
  default     = "true"
}