# Create private route table
resource "aws_route_table" "privatertb" {
    vpc_id = aws_vpc.prophius.id

    tags = {
        Name = "Private Route Table"
    }
}

# Create public route table
resource "aws_route_table" "publicrtb" {
    vpc_id = aws_vpc.prophius.id

    tags = {
        Name = "Public Route Table"
    }
}

# Create route for the private route table
resource "aws_route" "privateroute" {
    route_table_id = aws_route_table.privatertb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
}

# Create route for the public route table
resource "aws_route" "publicroute" {
    route_table_id = aws_route_table.publicrtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "privateasso" {
  count = length(aws_subnet.private[*].id)
  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.privatertb.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "publicasso" {
  count = length(aws_subnet.public[*].id)
  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.publicrtb.id
}