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
  //default = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}
variable "availability_zones" {
  description = "availability zone to create subnet1"
  type = list(string)
  //default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


variable "cidr_route_table" {
  description = "CIDR block for the route table"
  type = string
  default = "0.0.0.0/0"
}