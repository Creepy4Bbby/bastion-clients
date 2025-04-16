variable "cluster_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "dns_prefix" {
  type = string
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
variable "node_count" {
  type    = number
  default = 1
}
variable "node_size" {
  type    = string
  default = "Standard_B2s"
}
