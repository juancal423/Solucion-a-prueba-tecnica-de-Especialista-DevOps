#!/bin/bash

set -e  # Salir en cualquier error
set -o pipefail

CLUSTER_NAME="devops-challenge"
IMAGE_NAME="devops-challenge:latest"
TAR_NAME="devops-challenge-latest.tar"
NAMESPACE="devops-challenge"

echo "🚀 [1/9] Instalando Kind si no está presente..."
if ! command -v kind &> /dev/null; then
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-$(uname)-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
fi

echo "☸️ [2/9] Creando cluster Kind llamado $CLUSTER_NAME..."
kind create cluster --name "$CLUSTER_NAME" || echo "⚠️  Ya existe un cluster con ese nombre."

echo "📦 [3/9] Construyendo imagen Docker: $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" .

echo "📤 [4/9] Exportando y cargando imagen al cluster Kind..."
docker save "$IMAGE_NAME" -o "$TAR_NAME"
kind load image-archive "$TAR_NAME" --name "$CLUSTER_NAME"

echo "🗂️ [5/9] Creando namespace Kubernetes: $NAMESPACE..."
kubectl create namespace "$NAMESPACE" || echo "⚠️  Namespace ya existe."

echo "🔐 [6/9] Creando secret 'app-secret' con valor mock..."
kubectl create secret generic app-secret \
  --from-literal=value=mock-secret \
  -n "$NAMESPACE" || echo "⚠️  Secret ya existe."

echo "📄 [7/9] Aplicando manifiestos..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo "⏳ [8/9] Esperando a que el deployment esté disponible..."
kubectl rollout status deployment/node-app -n "$NAMESPACE"

echo "✅ [9/9] Probando endpoint /health..."
kubectl port-forward deployment/node-app 3000:3000 -n "$NAMESPACE" &
PF_PID=$!
sleep 3
curl -s http://localhost:3000/health | grep '"status":"ok"' && echo "✔️  Servicio responde correctamente." || echo "❌ Falló la validación del endpoint."
kill $PF_PID
