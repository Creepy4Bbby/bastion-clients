variable "resource_group" {
  type    = string
  default = "rg-teleport-efrei"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  default     = "teleport-aks"
}

# ---------

variable "agent_count" {
  description = "The number of agents to deploy"
  default     = 2
}

variable "ssh_public_key" {
  description = "The public key to use for SSH access"
  default     = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  description = "The DNS prefix to use for the public IP address"
  default     = "teleport"
}

variable "teleport" {
  description = "The name of the Kubernetes cluster"
  default     = "teleport"
}


# ---------