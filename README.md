# AWS EKS with Istio Service Mesh

This repository contains Terraform and Helm configurations to deploy an Amazon EKS (Elastic Kubernetes Service) cluster with Istio Service Mesh. The setup includes the necessary AWS infrastructure, EKS cluster, and Istio components to enable service mesh capabilities.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Terraform Configuration](#terraform-configuration)
4. [Helm Configuration](#helm-configuration)
5. [Deployment Steps](#deployment-steps)
6. [Cleanup](#cleanup)
7. [Contributing](#contributing)
8. [License](#license)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Terraform**: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI**: [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **Helm**: [Install Helm](https://helm.sh/docs/intro/install/)
- **AWS Account**: Ensure you have an AWS account with the necessary permissions to create EKS clusters, VPCs, and other resources.

## Architecture Overview

The architecture consists of the following components:

- **VPC**: A Virtual Private Cloud (VPC) with public and private subnets.
- **EKS Cluster**: A managed Kubernetes cluster running on AWS.
- **Istio Service Mesh**: Istio components (Istiod, Istio Gateway, and Istio Base) deployed using Helm.
- **Node Groups**: Managed node groups for running workloads on the EKS cluster.
- **AWS Load Balancer Controller**: Manages Application Load Balancers (ALBs) for Kubernetes services and Ingress resources.

## Terraform Configuration

The Terraform configuration is organized into several files:

- **NormalProvider.tf**: Configures the AWS provider and Terraform settings.
- **VPC.tf**: Defines the VPC and associated resources.
- **IGW.tf**: Creates an Internet Gateway for the VPC.
- **Subnets.tf**: Defines public and private subnets.
- **NAT.tf**: Configures a NAT Gateway for private subnets.
- **Routes_and_RTAssociations.tf**: Sets up route tables for public and private subnets.
- **EKS.tf**: Defines the EKS cluster and associated IAM roles.
- **Nodes.tf**: Configures the node groups for the EKS cluster.
- **IAM_role_n_policy_for_EBSCSI_Driver.tf**: Creates IAM roles and policies for the EBS CSI driver.
- **IAM_role_n_policy_for_elb_addon.tf**: Creates IAM Roles and Policies for the AWS Load Balancer Controller.
- **Create_IAM_OIDC_Provider.tf**: Configures OpenID Connect (OIDC) for EKS.
- **EBS_CSI_Driver_AddOn.tf**: Adds the EBS CSI driver to the EKS cluster.
- **HelmProvider.tf**: Configures the Helm provider for deploying Istio.
- **helm_deploy_Istiod.tf**: Deploys Istiod (Istio control plane) using Helm.
- **helm_deploy_IstioBase.tf**: Deploys the Istio base component using Helm.
- **helm_deploy_IstioGateway.tf**: Deploys the Istio Gateway using Helm.
- **helm_deploy_elb.tf**: Deploys the AWS Load Balancer Controller Using Helm.

## Helm Configuration

The Helm configuration includes default values for Istio components:

- **istiod-default.yaml**: Default configuration for Istiod.
- **istio-base-default.yaml**: Default configuration for Istio base.
- **gateway-default.yaml**: Default configuration for Istio Gateway.

## Deployment Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/AWS_EKS_Istio_ServiceMesh.git
   cd AWS_EKS_Istio_ServiceMesh
   ```

2. **Initialize Terraform**:
   ```bash
   cd eks-tf
   terraform init
   ```

3. **Apply Terraform Configuration**:
   ```bash
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks --region us-west-2 update-kubeconfig --name demo
   ```

5. **Deploy Istio using Helm**:
   ```bash
   helm repo add istio https://istio-release.storage.googleapis.com/charts
   helm repo update
   helm install my-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system
   helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system
   helm install gateway -n istio-ingress --create-namespace istio/gateway
   ```

6. **Deploy the AWS Load Balancer Controller using Helm:**:
   ```bash
   helm repo add eks https://aws.github.io/eks-charts
   helm repo update
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=demo --set serviceAccount.create=true --set serviceAccount.name=aws-load-balancer-controller
   ```

7. **Verify Deployment**:
   ```bash
   kubectl get pods -n istio-system
   kubectl get pods -n istio-ingress
   kubectl get pods -n kube-system | grep aws-load-balancer-controller
   ```

## Cleanup

To destroy the resources created by Terraform:

```bash
terraform destroy
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

This README provides a comprehensive guide to setting up an EKS cluster with Istio Service Mesh using Terraform and Helm. Follow the steps carefully to ensure a successful deployment.




# ***TEST CASES***
## Docker build
docker build -t harikrishnapachava/eksistiodemo:latest .  

## Docker tag and Push
docker tag eksistiodemo:latest harikrishnapachava/eksistiodemo:latest  # Optional if already tagged during build
docker push harikrishnapachava/eksistiodemo:latest 

## login to client pod 
kubectl exec -it client -n backend  -- sh  

## Client pod (SVC) to Service mesh service communication
while true; do curl http://ss-app.staging:8080/api/devices && echo "" && sleep 1; done

## Check the service accessibility
curl --header "Host: app.devopsbyexample.com" http://a452005df59a84ee4bf08fd07236bd96-2027597711.us-west-2.elb.amazonaws.com/api/devices 

## Windows 
Invoke-WebRequest -Uri "http://a452005df59a84ee4bf08fd07236bd96-2027597711.us-west-2.elb.amazonaws.com/api/devices" -Headers @{"Host"="app.devopsbyexample.com"}
