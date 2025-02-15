IAM OIDC (OpenID Connect) authentication for an Amazon EKS (Elastic Kubernetes Service) cluster is a method that allows you to use AWS Identity and Access Management (IAM) roles to authenticate and authorize users and applications within your Kubernetes cluster. This integration leverages the OIDC protocol, which is an identity layer built on top of OAuth 2.0, to provide a secure and scalable way to manage access to your EKS cluster.

### How IAM OIDC Authentication Works for EKS:

1. **OIDC Identity Provider**:
   - AWS EKS can be configured to use an OIDC identity provider. This provider is used to issue JWT (JSON Web Tokens) that can be verified by Kubernetes.
   - You create an OIDC identity provider in your AWS account that points to the EKS cluster's OIDC issuer URL.

2. **Service Account Annotations**:
   - In Kubernetes, you create a service account and annotate it with the IAM role that you want to associate with it. This role defines the permissions that the service account will have within AWS.
   - The annotation looks something like this:
     ```yaml
     apiVersion: v1
     kind: ServiceAccount
     metadata:
       name: my-service-account
       namespace: default
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-iam-role
     ```

3. **Trust Relationship**:
   - The IAM role that you associate with the service account must have a trust relationship that allows the OIDC provider to assume the role. This is configured in the IAM role's trust policy.
   - The trust policy might look like this:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B716EXAMPLE"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
             "StringEquals": {
               "oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B716EXAMPLE:sub": "system:serviceaccount:default:my-service-account"
             }
           }
         }
       ]
     }
     ```

4. **Kubernetes Authentication**:
   - When a pod is created with the annotated service account, Kubernetes will automatically inject the necessary environment variables and volume mounts to allow the pod to assume the IAM role.
   - The pod can then use the AWS SDK or CLI to interact with AWS services, and the permissions will be governed by the IAM role associated with the service account.

### Benefits of IAM OIDC Authentication for EKS:

- **Fine-Grained Access Control**: You can define precise IAM policies that control what actions the pods can perform within AWS.
- **No Need for Long-Term Credentials**: IAM roles are temporary and automatically rotated, reducing the risk of credential leakage.
- **Seamless Integration**: This method integrates smoothly with Kubernetes service accounts, making it easier to manage permissions at the pod level.
- **Scalability**: As your EKS cluster grows, you can easily manage permissions for new pods and services using IAM roles.

### Use Cases:

- **Microservices**: Different microservices running in your EKS cluster can have different IAM roles, allowing them to access specific AWS resources.
- **CI/CD Pipelines**: CI/CD tools running in Kubernetes can assume IAM roles to deploy applications or manage infrastructure.
- **Data Processing**: Pods that need to access S3 buckets, DynamoDB tables, or other AWS services can do so securely using IAM roles.

#
#
#
#

# **High-Level Steps for EKS Authentication and Authorization**

# **For Kubernetes Services/Objects to Use IAM Roles (Service Account-Based Access)**
This is for workloads (Pods) running in the EKS cluster that need to interact with AWS services.

1. **Enable OIDC Provider for EKS**:
   - Ensure your EKS cluster has an OIDC provider configured.
   - Use the EKS OIDC Issuer URL to create an OIDC identity provider in IAM.

2. **Create an IAM Role**:
   - Create an IAM role with the necessary permissions (e.g., access to S3, DynamoDB, etc.).
   - Update the role's trust policy to allow the OIDC provider to assume the role. Example:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "Federated": "arn:aws:iam::<account-id>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<oidc-id>"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
             "StringEquals": {
               "oidc.eks.<region>.amazonaws.com/id/<oidc-id>:sub": "system:serviceaccount:<namespace>:<service-account-name>"
             }
           }
         }
       ]
     }
     ```

3. **Create a Kubernetes Service Account**:
   - Create a Kubernetes service account and annotate it with the IAM role ARN. Example:
     ```yaml
     apiVersion: v1
     kind: ServiceAccount
     metadata:
       name: my-service-account
       namespace: default
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<iam-role-name>
     ```

4. **Use the Service Account in Pod Definitions**:
   - Specify the service account in your Pod definition. Example:
     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: my-pod
     spec:
       serviceAccountName: my-service-account
       containers:
       - name: my-container
         image: my-image
     ```

---



# **For Users to Access Kubernetes Resources Through `kubectl`**
## Ex: Allow users in an IAM group (e.g., `myk8sadmins`) to connect to your Amazon EKS cluster
To allow users in an IAM group (e.g., `myk8sadmins`) to connect to your Amazon EKS cluster using `kubectl` and perform operations like creating, deleting, and managing Kubernetes objects, you need to configure **AWS IAM** and **Kubernetes RBAC (Role-Based Access Control)**.

---

### **Step 1: Configure IAM for EKS Access**
1. **Create an IAM Policy for EKS Access**:
   - Create an IAM policy that allows users to interact with the EKS cluster.
   - Example policy (`eks-access-policy.json`):
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "eks:DescribeCluster",
             "eks:ListClusters"
           ],
           "Resource": "*"
         }
       ]
     }
     ```
   - Attach this policy to the IAM group `myk8sadmins`.

2. **Ensure Users Can Assume Roles**:
   - If your users need to assume roles (e.g., for cross-account access), ensure the IAM group has the necessary permissions to assume roles.

---

### **Step 2: Map IAM Users/Groups to Kubernetes RBAC**
1. **Enable IAM OIDC Provider for Your EKS Cluster**:
   - Ensure your EKS cluster has an OIDC provider configured. You can check this in the AWS Management Console under **EKS > Your Cluster > Configuration > OIDC Provider**.
   - If not enabled, follow the [AWS guide](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) to set it up.

2. **Create a Kubernetes Role and RoleBinding**:
   - Define a Kubernetes `Role` or `ClusterRole` with the necessary permissions (e.g., create, delete, update resources).
   - Bind this role to the IAM group `myk8sadmins` using a `RoleBinding` or `ClusterRoleBinding`.

   Example:
   ```yaml
   # Create a ClusterRole with admin permissions
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     name: eks-admin-role
   rules:
   - apiGroups: ["*"]
     resources: ["*"]
     verbs: ["*"]
   ---
   # Bind the ClusterRole to the IAM group
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: eks-admin-binding
   subjects:
   - kind: Group
     name: myk8sadmins  # This must match the IAM group name
     apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: ClusterRole
     name: eks-admin-role
     apiGroup: rbac.authorization.k8s.io
   ```

3. **Map IAM Group to Kubernetes RBAC**:
   - Update the `aws-auth` ConfigMap in the `kube-system` namespace to map the IAM group `myk8sadmins` to the Kubernetes RBAC group.

   Example:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: aws-auth
     namespace: kube-system
   data:
     mapRoles: |
       - rolearn: arn:aws:iam::123456789012:role/my-iam-role
         username: system:node:{{EC2PrivateDNSName}}
         groups:
           - system:bootstrappers
           - system:nodes
     mapUsers: |
       - userarn: arn:aws:iam::123456789012:user/my-user
         username: my-user
         groups:
           - myk8sadmins
     mapGroups: |
       - grouparn: arn:aws:iam::123456789012:group/myk8sadmins
         username: myk8sadmins
         groups:
           - myk8sadmins
   ```

   Apply the ConfigMap:
   ```bash
   kubectl apply -f aws-auth-configmap.yaml
   ```

---

### **Step 3: Configure `kubectl` for IAM Users**
1. **Install and Configure `awscli`**:
   - Ensure the users in the `myk8sadmins` group have the AWS CLI installed and configured with their IAM credentials.

2. **Update `kubeconfig` for EKS Access**:
   - Each user should update their `kubeconfig` file to authenticate with the EKS cluster using their IAM credentials.
   - Run the following command:
     ```bash
     aws eks update-kubeconfig --region <region> --name <cluster-name>
     ```
   - This command automatically configures `kubectl` to use the IAM user's credentials to authenticate with the EKS cluster.

3. **Verify Access**:
   - Users can verify their access by running:
     ```bash
     kubectl get pods --all-namespaces
     ```
   - If the RBAC and IAM configurations are correct, they should be able to perform operations like creating, deleting, and managing Kubernetes resources.

---

### **Step 4: Test and Troubleshoot**
1. **Test Permissions**:
   - Have users in the `myk8sadmins` group test their permissions by creating, deleting, and managing resources in the cluster.

2. **Troubleshoot Access Issues**:
   - If users cannot access the cluster, check the following:
     - Ensure the IAM group has the correct permissions.
     - Verify the `aws-auth` ConfigMap is correctly configured.
     - Check the Kubernetes RBAC roles and bindings.
     - Ensure the OIDC provider is correctly set up for the EKS cluster.

---

### **Summary**
By following these steps, you can grant users in the myk8sadmins IAM group access to your EKS cluster using kubectl. They will be able to create, delete, and manage Kubernetes objects based on the permissions defined in the Kubernetes RBAC roles and bindings. This approach leverages AWS IAM and Kubernetes RBAC for secure and fine-grained access control.

