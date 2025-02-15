# Add the EBS CSI driver to the EKS cluster
resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.demo.name # Name of the EKS cluster
  addon_name               = "aws-ebs-csi-driver"     # Name of the add-on
  addon_version            = "v1.29.1-eksbuild.1"     # Version of the add-on
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn # IAM role for the add-on
}
