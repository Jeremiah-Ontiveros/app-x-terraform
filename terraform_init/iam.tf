# Create the IAM user
resource "aws_iam_user" "cost_management_user" {
  name = "cost-management-user"
}

# Attach the AWSCostExplorerReadOnlyAccess policy to the user
resource "aws_iam_user_policy_attachment" "cost_management_policy_attachment" {
  user       = aws_iam_user.cost_management_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

# Create an access key for programmatic access
resource "aws_iam_access_key" "cost_management_access_key" {
  user = aws_iam_user.cost_management_user.name
}

# Create the IAM user
resource "aws_iam_user" "aws_deployment_user" {
  name = "aws_deployment_user"
}

resource "aws_iam_user_policy_attachment" "s3_access" {
  user       = aws_iam_user.aws_deployment_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "eks_access" {
  user       = aws_iam_user.aws_deployment_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "ecr_access" {
  user       = aws_iam_user.aws_deployment_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_user_policy_attachment" "iam_access" {
  user       = aws_iam_user.aws_deployment_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "DeploymentUserDynamoDBAccess"
  description = "Custom policy for DynamoDB access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable"
        ]
        Resource = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/app-x-dynamodb-*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "dynamodb_access" {
  user       = aws_iam_user.aws_deployment_user.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Create an access key for programmatic access
resource "aws_iam_access_key" "aws_deployment_user_access_key" {
  user = aws_iam_user.aws_deployment_user.name
}

# Variables and data for region and account ID
variable "region" {
  default = "us-east-1"
}

data "aws_caller_identity" "current" {}

#resource "aws_iam_policy" "s3_full_access" {
#  name        = "s3_full_access"
#  description = "Full access to the specific S3 bucket"
#  policy      = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "s3:ListBucket",
#        "s3:GetObject",
#        "s3:PutObject",
#        "s3:DeleteObject"
#      ],
#      "Resource": [
#        "arn:aws:s3:::jeremiah-ontiveros-resume.info",
#        "arn:aws:s3:::jeremiah-ontiveros-resume.info/*"
#      ]
#    }
#  ]
#}
#POLICY
#}
#
#resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
#  user       = aws_iam_user.aws_deployment_user.name
#  policy_arn = aws_iam_policy.s3_full_access.arn
#}