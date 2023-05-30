resource "aws_ecr_repository" "yelbui-demo" {
  name = "yelbui-demo"
}

resource "aws_ecr_repository" "yelbdb-demo" {
  name = "yelbdb-demo"
}

resource "aws_ecr_repository" "yelbserver-demo" {
  name = "yelbserver-demo"
}

resource "aws_eks_cluster" "circle_cluster" {
  name     = "circleci-demoeks"
  role_arn = "arn:aws:iam::237889007525:role/circlecieks"
  version  = "1.26"

  vpc_config {
    subnet_ids = ["subnet-0da6f97dce547daef", "subnet-075bdbf3a0123ebf0"]
  }

  /* depends_on = [aws_iam_role_policy_attachment.circle_eks_cluster_policy_attachment] */
}

resource "aws_eks_node_group" "circle_node_group" {
  cluster_name    = aws_eks_cluster.circle_cluster.name
  node_group_name = "circle-node-group"

  node_role_arn = "arn:aws:iam::237889007525:role/circle_worker"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }
		
		subnet_ids = ["subnet-0812c6debf7d11d7a", "subnet-08105596cb194fb57"]

  depends_on = [aws_eks_cluster.circle_cluster]
}
/* 
resource "aws_iam_role" "circle_eks_cluster_role" {
  name = "circle-eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "circle_eks_cluster_policy_attachment" {
  role       = aws_iam_role.circle_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "circle_node_group_role" {
  name = "circle-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "circle_node_group_instance_profile" {
  name = "circle-node-group-instance-profile"

  role = aws_iam_role.circle_node_group_role.name
} */