#!/bin/bash
set -e

# Script de instalación completo de Rancher v2.8.3
# Compatible con Ubuntu 22.04 LTS

echo "==========================================="
echo " 🚀 Instalador completo de Rancher v2.8.3"
echo "==========================================="

# 0️⃣ Variables
RANCHER_VERSION="${RANCHER_VERSION:-v2.8.3}"
DATA_DIR="/opt/rancher"
MAX_RETRIES=30
SLEEP_TIME=10

# 1️⃣ Actualización y dependencias
echo "🔧 Actualizando sistema e instalando dependencias..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    net-tools \
    software-properties-common \
    unzip \
    vim

# 2️⃣ Instalación de Docker
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
    docker --version
fi

# 3️⃣ Limpieza previa de contenedores y volúmenes Rancher
echo "🧹 Limpiando instalaciones previas de Rancher..."
sudo docker rm -f rancher >/dev/null 2>&1 || true
sudo docker rmi -f rancher/rancher:latest >/dev/null 2>&1 || true
sudo docker rmi -f rancher/rancher:$RANCHER_VERSION >/dev/null 2>&1 || true
sudo docker volume prune -f >/dev/null 2>&1 || true

# 4️⃣ Crear directorio persistente
echo "📁 Creando directorio persistente en $DATA_DIR..."
sudo mkdir -p $DATA_DIR
sudo chown -R $USER:$USER $DATA_DIR
sudo chmod 755 $DATA_DIR

# 5️⃣ Despliegue de Rancher
echo "🚀 Desplegando Rancher $RANCHER_VERSION..."
sudo docker run --privileged -d --restart=unless-stopped \
    --name rancher \
    -p 80:80 -p 443:443 \
    -v $DATA_DIR:/var/lib/rancher \
    rancher/rancher:$RANCHER_VERSION

# 6️⃣ Esperar y verificar contenedor
echo "⏳ Esperando que Rancher arranque (esto puede tomar varios minutos)..."
retry_count=0
until [ "$(sudo docker inspect -f '{{.State.Health.Status}}' rancher 2>/dev/null || echo "starting")" == "healthy" ]; do
    ((retry_count++))
    if [ $retry_count -ge $MAX_RETRIES ]; then
        echo "❌ Rancher no respondió tras $MAX_RETRIES intentos ($((MAX_RETRIES * SLEEP_TIME / 60)) minutos)."
        echo "📋 Revisa logs con: sudo docker logs -f rancher"
        exit 1
    fi
    echo "⏳ Intento $retry_count/$MAX_RETRIES: esperando Rancher... ($(($retry_count * SLEEP_TIME))s transcurridos)"
    sleep $SLEEP_TIME
done

# 7️⃣ Obtener información de acceso
echo ""
echo "✅ Rancher está disponible y saludable."
echo "==========================================="
echo "📊 Información de Acceso"
echo "==========================================="

# Obtener IP pública (funciona en Azure)
PUBLIC_IP=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" 2>/dev/null || hostname -I | awk '{print $1}')

echo "🔗 URL de Rancher: https://$PUBLIC_IP"
echo ""
echo "🔑 Bootstrap Password:"
sudo docker logs rancher 2>&1 | grep "Bootstrap Password:" | head -n 1
echo ""
echo "📋 Comandos útiles:"
echo "  Ver logs:     sudo docker logs -f rancher"
echo "  Reiniciar:    sudo docker restart rancher"
echo "  Estado:       sudo docker ps"
echo "==========================================="
echo ""
echo "⚠️  IMPORTANTE:"
echo "   1. Accede a https://$PUBLIC_IP"
echo "   2. Usa el Bootstrap Password mostrado arriba"
echo "   3. Configura una nueva contraseña"
echo "   4. Configura el Rancher Server URL"
echo "==========================================="
