# This section sets up an IAM role that allows the AWS Elastic Block Store (EBS) Container Storage Interface (CSI) driver to interact with AWS services.

# Step 1: Define an IAM policy for the EBS CSI driver
# This policy grants the EBS CSI driver permission to assume the IAM role via OIDC authentication.
# The condition ensures that only the EBS CSI service account (ebs-csi-controller-sa) in the kube-system namespace can use this role.
# The principals field links it to the OIDC provider of the EKS cluster.

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

#Step 2: Create an IAM role for the EBS CSI driver
# Creates an IAM role that can be assumed by the EBS CSI driver via OIDC.

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver"
}


#Step 3: Attach the AmazonEBSCSIDriverPolicy to the IAM role
# Grants the AmazonEBSCSIDriverPolicy, allowing the CSI driver to:
# Attach/detach EBS volumes.
# Create/delete EBS volumes dynamically.

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
