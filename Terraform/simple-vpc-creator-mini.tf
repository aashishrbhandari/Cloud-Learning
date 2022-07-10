resource "aws_vpc" "Trail-Dev-VPC" {
  cidr_block = "10.30.0.0/16"
  tags = {
    Name = "Trail-Dev-VPC"
  }
}
