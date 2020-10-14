variable "region" {
  description = "Region"
  type = string
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  type = string
}
variable "subnets_cidr" {
  description = "CIDR block for the subnet"
  type = list(string)
}
variable "availability_zones" {
  description = "availability zone to create subnet1"
  type = list(string)
}


variable "cidr_route_table" {
  description = "CIDR block for the route table"
  type = string
  default = "0.0.0.0/0"
}