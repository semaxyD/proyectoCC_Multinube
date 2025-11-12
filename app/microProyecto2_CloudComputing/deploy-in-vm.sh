#!/bin/bash
# deploy-in-vm.sh - Script para desplegar MicroProyecto2 dentro de Vagrant VM

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     🚀 MicroProyecto2 - Despliegue en Vagrant VM         ║
║           Kubernetes Local (k8sLocal)                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar que estamos en la VM
if [ ! -d "/vagrant/microProyecto2_CloudComputing" ]; then
    echo -e "${RED}❌ ERROR: No se encuentra la carpeta del proyecto${NC}"
    echo "Este script debe ejecutarse dentro de la Vagrant VM"
    echo "La carpeta /vagrant/microProyecto2_CloudComputing no existe"
    echo ""
    echo "Solución:"
    echo "  1. Asegúrate de estar dentro de la VM: vagrant ssh"
    echo "  2. Verifica que Vagrant montó la carpeta: ls -la /vagrant/"
    exit 1
fi

# Ir a la carpeta del proyecto
cd /vagrant/microProyecto2_CloudComputing

echo -e "${GREEN}✅ Carpeta del proyecto encontrada${NC}"
echo ""

# Verificar prerequisitos
echo -e "${BLUE}🔍 Verificando prerequisitos...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ docker no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ docker: $(docker --version)${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ minikube no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ minikube: $(minikube version --short 2>/dev/null || minikube version)${NC}"

# Verificar que Minikube está corriendo
echo ""
echo -e "${BLUE}🔍 Verificando estado de Minikube...${NC}"
if ! minikube status -p k8sLocal &> /dev/null; then
    echo -e "${YELLOW}⚠️  Minikube no está corriendo${NC}"
    echo "Iniciando Minikube..."
    minikube start -p k8sLocal --driver=docker
fi

MINIKUBE_STATUS=$(minikube status -p k8sLocal -o json | jq -r '.Host')
if [ "$MINIKUBE_STATUS" != "Running" ]; then
    echo -e "${YELLOW}⚠️  Minikube no está en estado Running${NC}"
    echo "Iniciando Minikube..."
    minikube start -p k8sLocal --driver=docker
fi

echo -e "${GREEN}✅ Minikube está corriendo${NC}"
echo ""

# Configurar kubectl context
kubectl config use-context k8sLocal > /dev/null

# Mostrar información del cluster
echo -e "${BLUE}📊 Información del Cluster:${NC}"
kubectl cluster-info
echo ""

MINIKUBE_IP=$(minikube ip -p k8sLocal)
echo -e "${GREEN}🌐 IP de Minikube: ${MINIKUBE_IP}${NC}"
echo ""

# Configurar Docker para usar Minikube
echo -e "${BLUE}🐳 Configurando Docker para usar daemon de Minikube...${NC}"
eval $(minikube docker-env -p k8sLocal)
echo -e "${GREEN}✅ Docker configurado${NC}"
echo ""

# Dar permisos a scripts
echo -e "${BLUE}🔐 Configurando permisos de scripts...${NC}"
chmod +x *.sh scripts/*.sh 2>/dev/null || true
echo -e "${GREEN}✅ Permisos configurados${NC}"
echo ""

# Preguntar si quiere desplegar
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  ¿Deseas desplegar la aplicación MicroStore ahora?       ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Esto hará:"
echo "  1. Construir 4 imágenes Docker (frontend, users, products, orders)"
echo "  2. Crear namespace 'microstore'"
echo "  3. Desplegar MySQL StatefulSet"
echo "  4. Desplegar los 4 microservicios"
echo "  5. Configurar Ingress"
echo ""
echo -e "${YELLOW}Esto puede tardar 5-10 minutos.${NC}"
echo ""
read -p "¿Continuar? (s/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo -e "${BLUE}📚 Para desplegar manualmente más tarde:${NC}"
    echo "   cd /vagrant/microProyecto2_CloudComputing"
    echo "   ./quickstart.sh"
    echo ""
    echo -e "${GREEN}✅ Entorno preparado. Sistema listo.${NC}"
    exit 0
fi

# Ejecutar despliegue
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🚀 Iniciando despliegue...                              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Ejecutar el script de despliegue de Minikube
if [ -f "./scripts/deploy-minikube.sh" ]; then
    ./scripts/deploy-minikube.sh
else
    echo -e "${YELLOW}⚠️  Script deploy-minikube.sh no encontrado${NC}"
    echo "Usando quickstart.sh..."
    ./quickstart.sh
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ DESPLIEGUE COMPLETADO                                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📱 URLs de acceso:${NC}"
echo "   Frontend:  http://${MINIKUBE_IP}/"
echo "   Users:     http://${MINIKUBE_IP}/users"
echo "   Products:  http://${MINIKUBE_IP}/products"
echo "   Orders:    http://${MINIKUBE_IP}/orders"
echo ""
echo -e "${BLUE}🔧 Comandos útiles:${NC}"
echo "   Ver pods:      kubectl get pods -n microstore"
echo "   Ver logs:      kubectl logs -f POD-NAME -n microstore"
echo "   Ver services:  kubectl get svc -n microstore"
echo "   Dashboard:     minikube dashboard -p k8sLocal"
echo ""
echo -e "${BLUE}💡 Para acceder desde Windows:${NC}"
echo "   1. Abrir navegador en Windows"
echo "   2. Ir a: http://${MINIKUBE_IP}/"
echo "   3. O usar port-forward:"
echo "      kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'"
echo "      Luego: http://192.168.56.10:8080"
echo ""
