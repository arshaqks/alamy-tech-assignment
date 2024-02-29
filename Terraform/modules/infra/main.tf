resource "aws_security_group" "my_security_group" {
    vpc_id = var.vpc_id

    dynamic "ingress" {
        for_each = var.security_rules.ingress
        content {
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    dynamic "egress" {
        for_each = var.security_rules.egress
        content {
            from_port   = egress.value.from_port
            to_port     = egress.value.to_port
            protocol    = egress.value.protocol
            cidr_blocks = egress.value.cidr_blocks
        }
    }
}

resource "aws_subnet" "mysubnet" {
    vpc_id         = var.vpc_id
    cidr_block     = var.cidr_block
    tags = {
        Name = var.name
    } 
}

resource "aws_instance" "myinstance" {
    ami            = var.ami
    instance_type  = var.instance_type
    subnet_id      = aws_subnet.mysubnet.id
    
    tags = {
        Name = var.name
    } 
    
}



