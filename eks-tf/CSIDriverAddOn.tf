# Installing the EBS CSI Driver in EKS
# This section installs the AWS EBS CSI driver as an EKS add-on.

# Step 1: Add the EBS CSI Driver to the EKS cluster
# Deploys the EBS CSI driver as an add-on to the EKS cluster.
# Uses the IAM role (eks-ebs-csi-driver) to interact with AWS EBS.
# The driver automates volume provisioning and attachment.

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.demo.name # Name of the EKS cluster
  addon_name               = "aws-ebs-csi-driver"     # Name of the add-on
  addon_version            = "v1.29.1-eksbuild.1"     # Version of the add-on
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn # IAM role for the add-on
}
