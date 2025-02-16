## Examples of a **Kubernetes Service** of type `ClusterIP` and an **Ingress resource** that will trigger the AWS Load Balancer Controller to create an Application Load Balancer (ALB).

---

### **Example: Ingress with `ClusterIP` Service**

Here’s how you can define an Ingress resource with a `ClusterIP` service:

#### **1. Backend Service (ClusterIP)**
This is the service that your application pods are exposed on internally.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: ClusterIP # Default type, no need to specify explicitly
  ports:
    - port: 80
      targetPort: 8080 # Port on which your application is running
  selector:
    app: my-app # Selector to match the pods
```

#### **2. Ingress Resource**
This resource creates an ALB and routes traffic to the `my-app-service`.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb # Use the AWS Load Balancer Controller
    alb.ingress.kubernetes.io/scheme: internet-facing # Public-facing ALB
    alb.ingress.kubernetes.io/target-type: ip # Use IP targets (recommended for EKS) (default is instance)
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]' # Listen on port 80
spec:
  rules:
    - host: my-app.example.com # Replace with your domain
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service # Backend ClusterIP service
                port:
                  number: 80
```

---
#### **Explanation:**
- **`kubernetes.io/ingress.class: alb`**: This annotation tells Kubernetes to use the AWS Load Balancer Controller to manage the ALB.
- **`alb.ingress.kubernetes.io/scheme: internet-facing`**: This creates a public-facing ALB. Use `internal` for a private ALB.
- **`alb.ingress.kubernetes.io/target-type: ip`**: This specifies that the ALB should use IP targets (recommended for EKS).
- **`alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'`**: This configures the ALB to listen on port 80 for HTTP traffic.
- **`host: my-app.example.com`**: Replace this with your domain name. If you don’t have a domain, you can omit this field to use the ALB's DNS name directly.

---

### **3. Deploy the Service and Ingress**

Save the above YAML files (e.g., `service.yaml` and `ingress.yaml`) and apply them to your EKS cluster:

```bash
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

---

### **4. Verify the ALB Creation**

After applying the YAML files, verify that the ALB is created and associated with your service or ingress:

1. **Check the Service:**
   ```bash
   kubectl get svc my-service
   ```
   Look for the `EXTERNAL-IP` field, which will show the DNS name of the ALB.

2. **Check the Ingress:**
   ```bash
   kubectl get ingress my-ingress
   ```
   Look for the `ADDRESS` field, which will show the DNS name of the ALB.

3. **Check the AWS Console:**
   - Go to the **EC2 Dashboard** in the AWS Management Console.
   - Navigate to **Load Balancers** under the **Load Balancing** section.
   - Verify that a new ALB has been created.

---

### **5. Test the ALB**

1. **For the Service:**
   - Use the DNS name from the `EXTERNAL-IP` field of the service to access your application:
     ```bash
     curl http://<ALB-DNS-NAME>
     ```

2. **For the Ingress:**
   - Use the DNS name from the `ADDRESS` field of the ingress to access your application:
     ```bash
     curl http://<ALB-DNS-NAME>
     ```
   - If you configured a custom domain (e.g., `my-app.example.com`), ensure that the DNS record points to the ALB's DNS name.

---

### **6. Clean Up**

To clean up the resources, delete the service and ingress:

```bash
kubectl delete -f service.yaml
kubectl delete -f ingress.yaml
```

This will automatically delete the associated ALB.

---
