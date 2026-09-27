variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "ap-south-1"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 Key Pair for SSH access"
  type        = string
}

variable "dockerhub_username" {
  description = "Your Docker Hub username"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret for User Service"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}
