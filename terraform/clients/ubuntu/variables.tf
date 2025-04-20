variable "resource_group_location" {
  type        = string
  default     = "francecentral"
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-teleport-efrei"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "ububu"
}
