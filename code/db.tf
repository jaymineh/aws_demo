resource "aws_db_subnet_group" "prophius-subnet" {
  name = "prophius-subnet"
  subnet_ids = [aws_subnet.private[2].id, aws_subnet.private[3].id]
}

resource "aws_db_instance" "MySQL" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  db_name = "ProphiusDB"
  username = var.master-username
  password = var.master-password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.prophius-subnet.name
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.sqlSG.id]
  multi_az = "false"
}