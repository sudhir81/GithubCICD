variable "location" {
  description = "Azure region to deploy"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for the sandbox"
  type        = string
  default     = "rg-sandbox"
}

variable "storage_account_name" {
  description = "Storage account name (for backend or other uses). Create this beforehand or change as needed."
  type        = string
  default     = "jumbodatastr1981"
}

variable "vm_admin_username" {
  description = "Local admin username for Windows VMs"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Admin password for VMs (sensitive) - provide via CI/CD secret or tfvars"
  type        = string
  sensitive   = true
}

variable "allowed_cidr" {
  description = "Source CIDR allowed for RDP/WinRM (set to your office IP/32). For CI testing you may set 0.0.0.0/0 (not recommended for production)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}
