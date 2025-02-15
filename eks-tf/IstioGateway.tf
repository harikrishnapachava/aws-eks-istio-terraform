# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install gateway -n istio-ingress --create-namespace istio/gateway

# Deploy Istio Gateway using Helm
resource "helm_release" "gateway" {
  name = "gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts" # Helm repository for Istio
  chart            = "gateway"                                           # Helm chart for Istio Gateway
  namespace        = "istio-ingress"                                     # Namespace for Istio Gateway
  create_namespace = true                                                # Create the namespace if it doesn't exist
  version          = "1.17.1"                                            # Version of Istio Gateway

  # Ensure Istio base and Istiod are deployed before the Gateway
  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}
