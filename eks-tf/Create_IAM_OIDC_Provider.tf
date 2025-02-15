#This section configures OIDC (OpenID Connect) authentication for the EKS cluster. It allows Kubernetes service accounts to assume IAM roles securely.

#Step 1: Retrieve the TLS certificate for the EKS cluster's OIDC Issuer
# Retrieves the TLS certificate for the OIDC Issuer of the EKS cluster.
# The aws_eks_cluster.demo.identity[0].oidc[0].issuer is the OIDC issuer URL of the EKS cluster.
data "tls_certificate" "eks" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

# Step 2: Create an IAM OpenID Connect (OIDC) provider in IAM, and point it to the EKS cluster OIDC Issuer URL
# Registers an OIDC provider for the EKS cluster, allowing IAM to trust Kubernetes service accounts.
# The thumbprint_list ensures secure communication.
# Why is this needed? - This enables Kubernetes ServiceAccounts to authenticate with AWS IAM without needing static credentials.
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"] # Client IDs for the OIDC provider
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint] # Thumbprint of the TLS certificate
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer # OIDC issuer URL
}
