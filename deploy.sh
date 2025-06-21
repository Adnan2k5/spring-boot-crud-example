#!/bin/bash

echo -e "Deploying Product to Kubernetes..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "kubectl is not installed."
    exit 1
fi

# Check if cluster can be accessed
if ! kubectl cluster-info &> /dev/null; then
    echo -e "Cannot connect to Kubernetes cluster.}"
    exit 1
fi

echo -e "kubectl and cluster connection verified"

# Create namespaces
echo -e "$Creating namespaces..."
kubectl apply -f kubernetes/namespaces/namespaces.yaml

echo -e "Waiting for namespaces to be ready..."
kubectl wait --for=condition=Active namespace/product-service-v1 --timeout=30s
kubectl wait --for=condition=Active namespace/product-service-v1-1 --timeout=30s
kubectl wait --for=condition=Active namespace/product-service-v2 --timeout=30s

# Apply ConfigMaps to each namespace
echo -e "{Running  ConfigMaps..."
kubectl apply -f kubernetes/configmaps/ConfigMaps.yaml -n product-service-v1
kubectl apply -f kubernetes/configmaps/ConfigMaps.yaml -n product-service-v1-1
kubectl apply -f kubernetes/configmaps/ConfigMaps.yaml -n product-service-v2

# Apply Secrets to each namespace
echo -e "$ Setting Secrets..."
if [ -f "kubernetes/secrets/db-secret.yaml" ]; then
    kubectl apply -f kubernetes/secrets/db-secret.yaml -n product-service-v1
    kubectl apply -f kubernetes/secrets/db-secret.yaml -n product-service-v1-1
    kubectl apply -f kubernetes/secrets/db-secret.yaml -n product-service-v2
else
    echo -e "db-secret.yaml not found, skipping secrets..."
fi

# Deploy applications
echo -e "Deploying applications.."
if [ -d "kubernetes/deployments" ]; then
    kubectl apply -f kubernetes/deployments/
else
    echo -e "deployments directory not found"
fi

# Create services
echo -e "Creating services.."
if [ -f "kubernetes/services/services.yaml" ]; then
    kubectl apply -f kubernetes/services/services.yaml
else
    echo -e "services.yaml not found"
fi

# Create HPA
echo -e "Setting up HPA"
if [ -f "kubernetes/hpa/scaler.yaml" ]; then
    kubectl apply -f kubernetes/hpa/scaler.yaml || echo -e " HPA requires metrics server"
else
    echo -e "scaler.yaml not found, skipping auto-scaling.."
fi

# Create Ingress
echo -e "Setting up ingress."
kubectl apply -f kubernetes/ingress/controller.yaml

echo -e "Deployment complete!"
echo ""

# Wait for deployments to be ready
echo -e "Waiting for deployments to be ready.."
kubectl rollout status deployment/product-service-v1 -n product-service-v1 --timeout=300s || true
kubectl rollout status deployment/product-service-v1-1 -n product-service-v1-1 --timeout=300s || true
kubectl rollout status deployment/product-service-v2 -n product-service-v2 --timeout=300s || true

echo -e " Checking deployment status.."
echo -e "Version 1.0:"
kubectl get pods -n product-service-v1 -o wide

echo -e "Version 1.1:"
kubectl get pods -n product-service-v1-1 -o wide

echo -e "Version 2.0:"
kubectl get pods -n product-service-v2 -o wide

echo -e "Services:"
kubectl get svc -n product-service-v1
kubectl get svc -n product-service-v1-1
kubectl get svc -n product-service-v2

echo -e "Ingress:"
kubectl get ingress -A

echo -e "HPA Status:"
kubectl get hpa -A 2>/dev/null || echo -e "HPA not available"

echo -e "Access Points:"
echo -e "v1.0: http://product-service.local/v1/api/v1/health"
echo -e "v1.1: http://product-service.local/v1.1/api/v1.1/health"
echo -e "v2.0: http://product-service.local/v2/api/v2/health"

echo -e " Deployment completed !"
