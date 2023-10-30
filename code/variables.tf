variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
    default = "40.0.0.0/16"
}

variable "preferred_number_of_public_subnets" {
    default = null
}

variable "preferred_number_of_private_subnets" {
    default = null
}

variable "ami" {
  default = "ami-026ebd4cfe2c043b2"
}

variable "name" {
  default = "Prophius"
  type = string
}

variable "keypair" {
    type = string
}

variable "account_no" {
    type = number
}

variable "master-username" {
    type = string
}

variable "master-password" {
    type = string 
}

variable "ecr" {
  type = string
  description = "ECR name"
}

variable "untagged_images" {
  type = string
}
