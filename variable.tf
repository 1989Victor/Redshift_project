variable "vpc_cidr_block" {
  description = "Value of the CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Value of the subent CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Value of the subent CIDR range for the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "internet_cidr" {
  description = "Value of the internet CIDR range for the VPC"
  type        = string
  default     = "0.0.0.0/0"
} 