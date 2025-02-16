# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system

# Deploy Istiod (Istio control plane) using Helm
resource "helm_release" "istiod" {
  name = "my-istiod-release"

  repository       = "https://istio-release.storage.googleapis.com/charts" # Helm repository for Istio
  chart            = "istiod"                                             # Helm chart for Istiod
  namespace        = "istio-system"                                       # Namespace for Istiod
  create_namespace = true                                                 # Create the namespace if it doesn't exist
  version          = "1.17.1"                                             # Version of Istiod

  # Configuration values for Istiod
  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }

  # Ensure Istio base is deployed before Istiod
  depends_on = [helm_release.istio_base]
}
