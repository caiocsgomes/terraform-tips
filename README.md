# Terraform Tips

This repository is where I save terraform stuff that I had to learn along the way in projects. If I ever stop in the same or similar problems again I can just come back to it and copy.

## Terraform functions

### How to format a string

```terraform
variable "cluster_name" {}

resource "aws_lb" "alb" {
  name = format("%s-alb", var.cluster_name)
}
```

### How to retrieve a list of properties from a property inside a list of maps

Lets say we need a list of all cidr blocks inside the VPC to create an ingress rule in a security group. The [`aws_vpc`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc#attributes-reference) data source has the `cidr_block_associations` that is a map list of all cidr blocks associations within the vpc. Inside this map we have the `cidr_block` property.

```terraform
data "aws_vpc" "default_vpc" {
  default = true
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    # The asterisk will do the trick here. This way we iterate over the associations and return all cidr blocks inside them.
    cidr_blocks      = data.aws_vpc.default_vpc.cidr_block_associations[*].cidr_block 
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
```

### Filter based on partial string

If we need to based on a string but we have only part of it, we can use an asterisk as a placeholder.

```terraform
data "aws_ami" "latest_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
```