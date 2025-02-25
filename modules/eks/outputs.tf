output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_auth_token" {
  description = "EKS authentication token"
  value       = data.aws_eks_cluster_auth.eks_auth.token
  sensitive   = true  
}
