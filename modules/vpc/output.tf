output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "vpc_id" {  # Add this
  value = aws_vpc.main.id
}