resource "aws_dynamodb_table" "app-x-aws_dynamodb_table" {
  name         = "app-x-dynamdb-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_iam_policy" "app_x_dynamodb_policy" {
  name        = "app-x-dynodb-policy"
  description = "Allows access to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      Resource = "arn:aws:dynamodb:us-east-2:123456789012:table/${aws_dynamodb_table.app-x-aws_dynamodb_table.name}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_x_dynamodb_role_attach" {
  role       = aws_iam_role.app_x_dynamodb_role.name
  policy_arn = aws_iam_policy.app_x_dynamodb_policy.arn
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = data.aws_eks_cluster.eks_cluster.name
}

data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# Ensure Service Account exists in Kubernetes
resource "kubernetes_service_account" "app_x_db_sa" {
  metadata {
    name      = "app-x-db-sa"
    namespace = "default"
  }
}

# Update the IAM Role for Kubernetes Authentication
resource "aws_iam_role" "app_x_dynamodb_role" {
  name = "app-x-dynodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEOIDC:sub" = "system:serviceaccount:default:app-x-db-sa"
        }
      }
    }]
  })
}

resource "aws_iam_user_policy" "eks_access" {
  name   = "EKSDescribeAccess"
  user   = "aws_deployment_user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "eks:DescribeCluster"
      Resource = "arn:aws:eks:us-east-2:123456789012:cluster/app-x-*"
    }]
  })
}
