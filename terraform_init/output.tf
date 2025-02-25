# Output the access key ID and secret access key
output "cost_management_access_key_id" {
  value = aws_iam_access_key.cost_management_access_key.id
}

output "cost_management_secret_access_key" {
  value     = aws_iam_access_key.cost_management_access_key.secret
  sensitive = true # Marks the output as sensitive to hide it in logs
}

output "aws_deployment_user_access_key_id" {
  value = aws_iam_access_key.aws_deployment_user_access_key.id
}

output "aws_deployment_user_secret_access_key" {
  value     = aws_iam_access_key.aws_deployment_user_access_key.secret
  sensitive = true 
}