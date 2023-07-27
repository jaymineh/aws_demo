resource "aws_security_group" "eksMain" {
  name = "EKS Main"
  description = "EKS Controller Traffic"
  vpc_id = aws_vpc.prophius.id

  dynamic "ingress" {
    iterator = port
    for_each = var.inEKSmain
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.outEKSmain
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = {
    Name = "eks Main"
  }
}

resource "aws_security_group" "eksNode" {
  name = "EKS Node"
  description = "EKS Node Traffic"
  vpc_id = aws_vpc.prophius.id

  dynamic "ingress" {
    iterator = port
    for_each = var.inEKSworker
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.outEKSworker
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = {
    Name = "eks Node"
  }
}

resource "aws_security_group" "ecrSG" {
  name = "ECR"
  description = "ECR traffic"
  vpc_id = aws_vpc.prophius.id

  dynamic "ingress" {
    iterator = port
    for_each = var.inECR
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.outECR
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = {
    Name = "ecrSG"
  }
}

resource "aws_security_group" "sqlSG" {
  name = "SQL"
  description = "SQL traffic"
  vpc_id = aws_vpc.prophius.id

  dynamic "ingress" {
    iterator = port
    for_each = var.inSQL
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.outSQL
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = {
    Name = "sqlSG"
  }
}