variable "zone" {
  description = "Use specific availability zone"
  type        = string
}

variable "cloud_id" {
  description = "Use specific cloud id"
  type        = string
  default     = "<INPUT>"
}

variable "folder_id" {
  description = "Use specific folder_id"
  type        = string
  default     = "<INPUT>"
}

variable "token" {
  description = "Use specific token"
  type        = string
  default     = "<INPUT>"
}

variable "instance_family_image" {
  description = "Instance image"
  type        = string
  default     = "lamp"
}

variable "vpc_subnet_id" {
  description = "VPC subnet network id"
  type        = string
}