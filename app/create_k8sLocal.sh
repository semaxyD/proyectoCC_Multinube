#!/bin/bash
set -euo pipefail

# create_k8sLocal.sh - Script de provisión para Vagrant VM
# Instala Docker, kubectl, Minikube y levanta cluster k8sLocal
# Preparado para trabajar con MicroProyecto2

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  � Instalación de Kubernetes Local (k8sLocal)           ║"
echo "║     Para MicroProyecto2 - Cloud Computing                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Este script corre como root pero configura para usuario vagrant
VAGRANT_USER="vagrant"
VAGRANT_HOME="/home/vagrant"

# 1️⃣ Actualizar repositorios
echo "📦 Actualizando repositorios del sistema..."
apt-get update -y
apt-get upgrade -y

# 2️⃣ Instalar utilidades básicas
echo "🔧 Instalando utilidades básicas..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    socat \
    conntrack \
    iptables \
    unzip \
    vim \
    git \
    jq \
    htop \
    net-tools \
    bridge-utils

# 3️⃣ Instalar Docker (para usar como driver de minikube)
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "✅ Docker ya instalado: $(docker --version)"
fi

# Configurar usuario vagrant para usar Docker sin sudo
usermod -aG docker $VAGRANT_USER
systemctl enable docker
systemctl start docker

# Configurar Docker daemon para mejor rendimiento
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl restart docker
sleep 3

# 4️⃣ Instalar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "☸️ Instalando kubectl..."
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl || true
else
    echo "✅ kubectl ya instalado: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
fi

# Habilitar autocompletado de kubectl para vagrant
sudo -u $VAGRANT_USER bash -c "kubectl completion bash > ${VAGRANT_HOME}/.kubectl_completion"
echo "source ${VAGRANT_HOME}/.kubectl_completion" >> ${VAGRANT_HOME}/.bashrc

# 5️⃣ Instalar Minikube
if ! command -v minikube &> /dev/null; then
    echo "⛏️ Instalando Minikube..."
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    mv minikube /usr/local/bin/
else
    echo "✅ Minikube ya instalado: $(minikube version --short 2>/dev/null || minikube version)"
fi

# 6️⃣ Verificación de dependencias
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Verificación de dependencias instaladas:"
echo "═══════════════════════════════════════════════════════════"
docker --version
kubectl version --client --short 2>/dev/null || kubectl version --client
minikube version --short 2>/dev/null || minikube version
echo "═══════════════════════════════════════════════════════════"
echo ""

# 7️⃣ Configuraciones de red para Kubernetes
echo "🌐 Configurando parámetros de red para Kubernetes..."
modprobe br_netfilter || true
modprobe overlay || true

cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
overlay
EOF

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system > /dev/null 2>&1 || true

# 8️⃣ Iniciar Minikube usando Docker driver
echo ""
echo "🚀 Iniciando cluster Kubernetes con Minikube..."
echo "   Perfil: k8sLocal"
echo "   Driver: docker"
echo "   Usuario: $VAGRANT_USER"
echo ""

# Limpiar instalación previa si existe
sudo -u $VAGRANT_USER minikube delete -p k8sLocal >/dev/null 2>&1 || true

# Iniciar Minikube como usuario vagrant
sudo -u $VAGRANT_USER -H bash -c "minikube start \
  -p k8sLocal \
  --driver=docker \
  --container-runtime=docker \
  --kubernetes-version=stable \
  --cpus=3 \
  --memory=4096 \
  --disk-size=20g \
  --extra-config=kubelet.housekeeping-interval=10s"

# 9️⃣ Configurar kubectl
echo "⚙️ Configurando kubectl..."
sudo -u $VAGRANT_USER kubectl config use-context k8sLocal

# 🔟 Esperar a que el nodo esté Ready
echo "⏳ Esperando que el nodo esté Ready..."
timeout=600
interval=5
elapsed=0

while true; do
  status=$(sudo -u $VAGRANT_USER kubectl get nodes --no-headers 2>/dev/null || true)
  if echo "$status" | grep -q ' Ready'; then
    echo ""
    echo "✅ Nodo Ready:"
    sudo -u $VAGRANT_USER kubectl get nodes
    break
  fi
  
  sleep $interval
  elapsed=$((elapsed + interval))
  printf "."
  
  if [ $elapsed -ge $timeout ]; then
    echo ""
    echo "❌ Timeout esperando nodo Ready"
    sudo -u $VAGRANT_USER kubectl get nodes -o wide || true
    exit 1
  fi
done

# 1️⃣1️⃣ Habilitar addons útiles
echo ""
echo "🔌 Habilitando addons de Minikube..."
sudo -u $VAGRANT_USER minikube addons enable ingress -p k8sLocal
sudo -u $VAGRANT_USER minikube addons enable metrics-server -p k8sLocal
sudo -u $VAGRANT_USER minikube addons enable dashboard -p k8sLocal

# 1️⃣2️⃣ Mostrar información del cluster
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ✅ Cluster k8sLocal completamente operativo             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Información del cluster:"
sudo -u $VAGRANT_USER kubectl cluster-info
echo ""
echo "🌐 IP de Minikube:"
sudo -u $VAGRANT_USER minikube ip -p k8sLocal
echo ""
echo "📂 Carpeta de proyecto:"
echo "   /vagrant/microProyecto2_CloudComputing"
echo ""
echo "🚀 Para desplegar tu aplicación:"
echo "   cd /vagrant/microProyecto2_CloudComputing"
echo "   ./quickstart.sh"
echo ""

# Fin del script
