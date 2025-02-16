# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install my-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system

# Deploy Istio base using Helm
resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts" # Helm repository for Istio
  chart            = "base"                                               # Helm chart for Istio base
  namespace        = "istio-system"                                       # Namespace for Istio base
  create_namespace = true                                                 # Create the namespace if it doesn't exist
  version          = "1.17.1"                                             # Version of Istio base

  # Configuration values for Istio base
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
}
