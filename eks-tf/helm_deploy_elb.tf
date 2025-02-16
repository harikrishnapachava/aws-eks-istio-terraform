# Deploy the AWS Load Balancer Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts" # Helm repository for AWS EKS charts
  chart      = "aws-load-balancer-controller"    # Helm chart for the AWS Load Balancer Controller
  namespace  = "kube-system"                     # Namespace for the controller
  version    = "1.5.3"                           # Version of the Helm chart

  set {
    name  = "clusterName"
    value = aws_eks_cluster.demo.name # Name of the EKS cluster
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn # IAM role for the controller
  }

  depends_on = [
    aws_eks_cluster.demo,
    aws_iam_role.alb_controller
  ]
}
