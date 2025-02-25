variable "eks_role_arn" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "subnet_ids" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = list(string)
}
variable "node_desired_size" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = number
}
variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "node_max_size" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = number
}

variable "node_min_size" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = number
}

variable "node_role_arn" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}


