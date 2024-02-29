variable "user" {
  description = "Name of the IAM user"
}

variable "role" {
  description = "Name of the IAM role"
}

variable "policy" {
  description = "Name of the IAM policy"
}

variable "ec2_service_principal" {
  description = "Service principal for EC2 (for trust policy)"
  default     = "ec2.amazonaws.com"
}

variable "policy_actions" {
  description = "Actions allowed by the IAM policy"
  type        = list(string)
  default     = ["ec2:Describe*"]
}