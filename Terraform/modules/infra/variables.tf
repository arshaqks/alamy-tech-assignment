variable "vpc_id" {
    description = "VPC for network"
}

variable "cidr_block" {
    description = "Subnet CIDR block for the VPC"
}

variable "tags" {
    description = "Tags to apply to resources"
}

variable "ami" {
    description = "AMI to use on the webserver instance"
}

variable "instance_type" {
    description = "value for the instance_type"
}

variable "name" {
    description = "Name for the webserver"
}

variable "security_rules" {
    description = "Security group rules"
    type = object({
        ingress = list(object({
            from_port   = number
            to_port     = number
            protocol    = string
            cidr_blocks = list(string)
        }))
        egress  = list(object({
            from_port   = number
            to_port     = number
            protocol    = string
            cidr_blocks = list(string)
        }))
    })
}
