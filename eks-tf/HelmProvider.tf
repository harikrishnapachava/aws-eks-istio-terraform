# Retrieve the EKS cluster details
data "aws_eks_cluster" "eks" {
  name = "demo"

  depends_on = [aws_eks_cluster.demo]
}

# Retrieve the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = "demo"

  depends_on = [aws_eks_cluster.demo]
}

# Configure the Helm provider for deploying Istio
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint # EKS cluster endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) # Cluster CA certificate
    token                  = data.aws_eks_cluster_auth.eks.token # Authentication token
  }
}
