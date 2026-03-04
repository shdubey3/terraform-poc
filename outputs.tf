output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_1_id" {
  description = "ID of subnet 1"
  value       = aws_subnet.subnet_1.id
}

output "subnet_1_cidr" {
  description = "CIDR block of subnet 1"
  value       = aws_subnet.subnet_1.cidr_block
}

output "subnet_2_id" {
  description = "ID of subnet 2"
  value       = aws_subnet.subnet_2.id
}

output "subnet_2_cidr" {
  description = "CIDR block of subnet 2"
  value       = aws_subnet.subnet_2.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "route_table_1_id" {
  description = "ID of route table for subnet 1"
  value       = aws_route_table.subnet_1.id
}

output "route_table_2_id" {
  description = "ID of route table for subnet 2"
  value       = aws_route_table.subnet_2.id
}
