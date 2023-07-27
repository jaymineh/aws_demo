# Create IGW
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.prophius.id

  tags = {
      Name = format("%s-%s-%s!", var.name, aws_vpc.prophius.id, "IG")
  }
}