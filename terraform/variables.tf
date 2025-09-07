variable "location" {
  description = "Azure region to deploy"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-ws2019-lab"
}

variable "vm_admin_username" {
  description = "Admin username for Windows VMs"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Admin password for Windows VMs (sensitive)"
  type        = string
  sensitive   = true
}

variable "allowed_cidr" {
  description = "Source CIDR allowed for RDP/WinRM (set to your IP/32 for production)"
  type        = string
  default     = "0.0.0.0/0"
}
