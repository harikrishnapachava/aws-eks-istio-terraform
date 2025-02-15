# Create an IAM role for the EKS cluster
resource "aws_iam_role" "demo" {
  name = "eks-istio-servicemesh-demo"

  # Define the trust relationship policy for the role
  assume_role_policy = <<POLICY
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
POLICY
}

# Attach the AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "demo_amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

# Create the EKS cluster
resource "aws_eks_cluster" "demo" {
  name     = "demo" # Name of the EKS cluster
  version  = "1.29" # Kubernetes version
  role_arn = aws_iam_role.demo.arn # IAM role for the cluster

  # Configure the VPC for the EKS cluster
  vpc_config {
    subnet_ids = [
      aws_subnet.private_us_west_2a.id,
      aws_subnet.private_us_west_2b.id,
      aws_subnet.public_us_west_2a.id,
      aws_subnet.public_us_west_2b.id
    ]
  }

  # Ensure the IAM role policy is attached before creating the cluster
  depends_on = [aws_iam_role_policy_attachment.demo_amazon_eks_cluster_policy]
}
