variable "domain_name" {
  description = "Domen"
  default     = "wolflife.net"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "subdomain" {
  description = "Subdomain"
  default     = "task3210"
}

variable "my_ip" {
  description = "My public IP for SSH "
  default     = "89.149.93.193/32"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "notes"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}