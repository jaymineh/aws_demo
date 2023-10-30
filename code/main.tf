# Get list of AZ
data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}

# Create EKS cluster
resource "aws_eks_cluster" "ProphiusEKS" {
  name = "ProphiusEKS"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  }

  depends_on = [ 
    aws_iam_role.eks-iam-role
   ]

  tags = {
    Name = "ProphiusEKSCLuster"
  }
}

# Create EKS worker nodes
resource "aws_eks_node_group" "ProphiusNode" {
  cluster_name = aws_eks_cluster.ProphiusEKS.name
  node_group_name = "ProphiusEKSnodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }

  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}