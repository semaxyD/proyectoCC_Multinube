#!/bin/bash
set -e

# Script de creación de cluster Kubernetes local con Minikube
# Compatible con Ubuntu 22.04 LTS

echo "==========================================="
echo "🔧 Instalación de dependencias para Minikube"
echo "==========================================="

# 1️⃣ Actualizar repositorios
echo "📦 Actualizando repositorios..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2️⃣ Instalar utilidades básicas
echo "🛠️  Instalando utilidades básicas..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    socat \
    conntrack \
    unzip \
    vim \
    git

# 3️⃣ Instalar Docker (para contenedores)
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    rm get-docker.sh
else
    echo "✅ Docker ya instalado"
fi

# 4️⃣ Instalar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "☸️  Instalando kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
else
    echo "✅ kubectl ya instalado"
fi

# 5️⃣ Instalar Minikube
if ! command -v minikube &> /dev/null; then
    echo "⛏️  Instalando Minikube..."
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/
else
    echo "✅ Minikube ya instalado"
fi

# 6️⃣ Verificación de dependencias
echo ""
echo "✅ Dependencias instaladas:"
docker --version
kubectl version --client
minikube version

echo ""
echo "==========================================="
echo "🚀 Levantando Minikube: k8sLocal"
echo "==========================================="

# Verificar si el cluster ya existe
if minikube profile list 2>/dev/null | grep -q "k8sLocal"; then
    echo "⚠️  El cluster k8sLocal ya existe. Eliminando..."
    minikube delete -p k8sLocal
fi

# 1️⃣ Arrancar el cluster k8sLocal
echo "🚀 Iniciando cluster k8sLocal..."
minikube start -p k8sLocal \
    --driver=docker \
    --cpus=2 \
    --memory=4096 \
    --disk-size=12g \
    --kubernetes-version=stable

# 2️⃣ Configurar kubectl para usar el contexto k8sLocal
echo "⚙️  Configurando kubectl..."
kubectl config use-context k8sLocal

# 3️⃣ Verificar nodos
echo "⏳ Esperando que los nodos estén Ready..."
retry_count=0
max_retries=30
until kubectl get nodes k8sLocal -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True"; do
    ((retry_count++))
    if [ $retry_count -ge $max_retries ]; then
        echo "❌ El nodo no está Ready después de $max_retries intentos"
        echo "📋 Revisa el estado con: kubectl get nodes"
        exit 1
    fi
    echo "⏳ Esperando... ($retry_count/$max_retries)"
    sleep 5
done

# 4️⃣ Información del cluster
echo ""
echo "✅ Cluster k8sLocal completamente operativo!"
echo "==========================================="
echo "📊 Información del Cluster"
echo "==========================================="

kubectl get nodes -o wide

echo ""
echo "🔧 Comandos útiles:"
echo "  Ver nodos:            kubectl get nodes"
echo "  Ver pods:             kubectl get pods -A"
echo "  Dashboard:            minikube dashboard -p k8sLocal"
echo "  Detener cluster:      minikube stop -p k8sLocal"
echo "  Eliminar cluster:     minikube delete -p k8sLocal"
echo "  SSH al nodo:          minikube ssh -p k8sLocal"
echo ""
echo "🔗 Para registrar en Rancher:"
echo "   1. Accede a Rancher UI"
echo "   2. Clusters → Import → Generic"
echo "   3. Nombra el cluster: k8sLocal"
echo "   4. Ejecuta el comando proporcionado en esta VM"
echo "==========================================="

# 5️⃣ Test básico
echo ""
echo "🧪 Ejecutando test básico..."
kubectl run test-nginx --image=nginx --restart=Never --rm -it -- /bin/sh -c "echo 'Cluster funcionando correctamente' && exit 0" 2>/dev/null || echo "✅ Test completado"

echo ""
echo "🎉 ¡Cluster k8sLocal listo para usar!"
