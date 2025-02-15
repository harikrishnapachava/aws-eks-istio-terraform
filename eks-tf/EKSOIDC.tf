# Retrieve the TLS certificate for the EKS cluster's OIDC provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

# Create an OpenID Connect (OIDC) provider for the EKS cluster
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"] # Client IDs for the OIDC provider
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint] # Thumbprint of the TLS certificate
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer # OIDC issuer URL
}
