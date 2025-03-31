variable "location" {
  default     = "westeurope"
  description = "Azure region"
}

variable "vm_size" {
  default     = "Standard_B2ms"
  description = "VM size (2 CPU, 8 GB RAM)"
}

variable "resource_group_name" {
  description = "Resource group name"
}

variable "vm_name" {
  default     = "monitoring-vm"
  description = "VM name"
}

variable "admin_username" {
  default     = "azureuser"
  description = "Admin username"
}

variable "ssh_public_key" {
  description = "SSH public key for access"
}
