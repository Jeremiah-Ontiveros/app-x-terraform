resource "aws_eks_cluster" "main" {
  name = "app-x-${var.env}-cluster"
  role_arn = var.eks_role_arn
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

}

resource "aws_eks_node_group" "workers" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "app-x-${var.env}-workers"
  node_role_arn = var.node_role_arn
  subnet_ids = var.subnet_ids
  scaling_config {
    desired_size = var.node_desired_size
    max_size = var.node_max_size
    min_size = var.node_min_size
  }
}

data "aws_eks_cluster_auth" "eks_auth" {
  name       = aws_eks_cluster.main.name
  depends_on = [aws_eks_cluster.main] 
}