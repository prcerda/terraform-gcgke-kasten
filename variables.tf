variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "az" {
  type = list(string)
}

variable "owner" {
  type = string
}

variable "activity" {
  type = string
}

variable "subnet_cidr_block_ipv4" {
    type = string
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
}

variable "cluster_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "tokenexpirehours" {
  type = number
  default = 36
}