locals {
  name = "${var.env}-${var.project_name}-${var.region}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name = "${local.name}-ROLE"
    project_name = var.project_name
    environment = var.env
    region = var.region
    Resource = "ROLE"
    Creation_time = timestamp()
  }
}

resource "aws_iam_role_policy_attachment" "policy-AmazonEKSClusterPolicy" {
  role = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "policy-AmazonEKSVPCResourceController" {
  role = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "${local.name}-EKS-CLUSTER"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = var.subnet_id
  }
  tags = {
    Name = "${local.name}-EKS-CLUSTER"
    project_name = var.project_name
    environment = var.env
    region = var.region
    Resource = "EKS-CLUSTER"
    Creation_time = timestamp()
  }
  depends_on = [ aws_iam_role_policy_attachment.policy-AmazonEKSClusterPolicy,aws_iam_role_policy_attachment.policy-AmazonEKSVPCResourceController ]
}

#node group

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-roles"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = {
    Name = "${local.name}-ROLE"
    project_name = var.project_name
    environment = var.env
    region = var.region
    Resource = "ROLE"
    Creation_time = timestamp()
  }
}



# resource "aws_iam_role" "eks_node_group_role" {
#   name               = "eks-nodegroup-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

resource "aws_iam_role_policy_attachment" "policy-AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "policy-AmazonEKS_CNI_Policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "policy-AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "policy-AdministratorAccess" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_eks_node_group" "node_group1" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.name}-NODE-GROUP"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids = var.subnet_id

  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }
  update_config {
    max_unavailable = 1
  }
  #ami_type = "none"

  //  # Remote access cannot be specified with a launch template
  //  remote_access = {
  //    ec2_ssh_key               = module.key_pair.key_pair_name
  //    source_security_group_ids = [aws_security_group.remote_access.id]
  //  }

  capacity_type = "SPOT"
  disk_size = "30"
  # instance_types = [ "t2.medium" ]
  ami_type = "AL2_ARM_64"
  instance_types = [ "t4g.large" ]


  labels = {
    ENVIRONMENT = "PRODUCTION"
    PROJECT = "ECOMMERCE"
    OWNER = "ASHIQ"
  }

  # taint {
  #   key = "APPLICATION"
  #   value = "ECOMMERCE"
  #   effect = "NO_SCHEDULE"
  # }
  tags = {
    Name = "${local.name}-NODE-GROUP"
    project_name = var.project_name
    environment = var.env
    region = var.region
    Resource = "NODE-GROUP"
    Creation_time = timestamp()
  }
  # lifecycle {
  #   create_before_destroy = true
  # }
  depends_on = [ aws_iam_role_policy_attachment.policy-AmazonEKSWorkerNodePolicy,aws_iam_role_policy_attachment.policy-AmazonEKS_CNI_Policy,aws_iam_role_policy_attachment.policy-AmazonEC2ContainerRegistryReadOnly ]
}

#update kubernetes config
resource "null_resource" "update_kubernetes_config" {
  depends_on = [ aws_eks_node_group.node_group1 ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.name}-EKS-CLUSTER --region ap-south-1"
  }
}
