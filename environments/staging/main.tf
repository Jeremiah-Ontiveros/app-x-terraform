module "vpc" {
  source              = "../../modules/vpc"
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source      = "../../modules/ecr"
  env         = var.env
  image_count = var.image_count
}

module "iam" {
  source = "../../modules/iam"
  env    = var.env
}

data "aws_eks_cluster" "eks_cluster" {
  name = "app-x-${var.env}-cluster"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = data.aws_eks_cluster.eks_cluster.name
}

module "eks" {
  source            = "../../modules/eks"
  env               = var.env
  subnet_ids        = module.vpc.private_subnet_ids
  eks_role_arn      = module.iam.eks_role_arn
  node_role_arn     = module.iam.node_role_arn
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size
  node_min_size     = var.node_min_size
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  env = var.env
  cluster_name = "app-x-${var.env}-cluster"
  depends_on = [ module.eks ]
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

resource "aws_lb" "app_lb" {
  name               = "app-x-${var.env}-lb"
  internal           = false 
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnet_ids
  tags               = { Name = "app-x-${var.env}-lb" }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-x-${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}