# Create an IAM role for the EKS node group
resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  # Define the trust relationship policy for the role
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
}

# Attach necessary policies to the IAM role for the node group
resource "aws_iam_role_policy_attachment" "nodes_amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Optional: Attach the AmazonSSMManagedInstanceCore policy for SSH access
resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodes.name
}

# Create the EKS node group
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.demo.name # Name of the EKS cluster
  node_group_name = "private-nodes"          # Name of the node group
  node_role_arn   = aws_iam_role.nodes.arn   # IAM role for the node group

  # Subnet for the node group
  subnet_ids = [
    aws_subnet.private_us_west_2a.id
  ]

  instance_types = ["t3.large"] # Instance type for the nodes

  # Scaling configuration for the node group
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Update configuration for the node group
  update_config {
    max_unavailable = 1
  }

  # Labels for the node group
  labels = {
    role = "general"
  }

  # Ensure the necessary policies are attached before creating the node group
  depends_on = [
    aws_iam_role_policy_attachment.nodes_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_amazon_ec2_container_registry_read_only,
  ]
}
