Microservicio Node.js con despliegue automatizado en Kubernetes local usando Kind.

---

## 🚀 Requisitos

- Docker  
- Node.js  
- kubectl  
- Kind  
- GitHub CLI (opcional)  

---

## 🧱 Instalación y configuración local

### 1. Instalar Kind

\`\`\`bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
\`\`\`

### 2. Crear el cluster Kind

\`\`\`bash
kind create cluster --name devops-challenge


\`\`\`

### 3. Crear el namespace

\`\`\`bash
kubectl create namespace devops-challenge
\`\`\`

---

## 🐳 Construir y cargar la imagen Docker

### 4. Construir la imagen Docker localmente

\`\`\`bash
docker build -t devops-challenge:latest .
\`\`\`

### 5. Cargar la imagen en el cluster Kind

\`\`\`bash
docker save devops-challenge:latest -o devops-challenge-latest.tar
kind load image-archive devops-challenge-latest.tar --name devops-challenge
\`\`\`

---

## ☸️ Desplegar en Kubernetes

### 6. Aplicar manifiestos

\`\`\`bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
\`\`\`

---

## 🔎 Validación

### 7. Verificar que el pod esté corriendo

\`\`\`bash
kubectl get pods -n devops-challenge
\`\`\`

### 8. Probar endpoint \`/health\`

Con port-forward:

\`\`\`bash
kubectl port-forward deployment/node-app 3000:3000 -n devops-challenge
\`\`\`

Luego:

\`\`\`bash
curl http://localhost:3000/health
\`\`\`

Deberías ver:

\`\`\`json
{"status":"ok"}
\`\`\`

---

## ⚙️ Pipeline CI/CD (GitHub Actions)

### Archivo \`.github/workflows/deploy.yml\` incluye:

- Lint (opcional)
- Build de la imagen Docker
- Crear cluster Kind
- Cargar imagen al cluster
- Aplicar manifests
- Validar despliegue

---

## 📝 Notas

- El secret \`app-secret\` se crea con un valor mock para cumplir el challenge.  
- Manifiestos separados por tipo para mejor organización.  
- El puerto expuesto es el 3000.  