#!/bin/bash
set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

clear

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                  ║${NC}"
echo -e "${CYAN}║      🚀 DESPLIEGUE UNIFICADO - MICROSTORE                       ║${NC}"
echo -e "${CYAN}║      Deploy to Multiple Kubernetes Environments                  ║${NC}"
echo -e "${CYAN}║                                                                  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Función para mostrar mensajes
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${MAGENTA}▶️  $1${NC}"
}

# Mostrar menú de selección
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Selecciona el entorno de despliegue${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}1)${NC} 🏠 Minikube (Local Development)"
echo -e "   ${CYAN}• Rápido para desarrollo y pruebas${NC}"
echo -e "   ${CYAN}• No consume créditos en la nube${NC}"
echo -e "   ${CYAN}• Imágenes Docker locales${NC}"
echo ""
echo -e "${GREEN}2)${NC} ☁️  Azure AKS (Cloud Production)"
echo -e "   ${CYAN}• Cluster en Azure Kubernetes Service${NC}"
echo -e "   ${CYAN}• Azure Container Registry${NC}"
echo -e "   ${CYAN}• Alta disponibilidad y escalabilidad${NC}"
echo ""
echo -e "${GREEN}3)${NC} 🌩️  AWS EKS (Cloud Production - Futuro)"
echo -e "   ${CYAN}• Cluster en Amazon Elastic Kubernetes Service${NC}"
echo -e "   ${CYAN}• Amazon ECR${NC}"
echo -e "   ${CYAN}• En desarrollo...${NC}"
echo ""
echo -e "${GREEN}4)${NC} 📊 Ver estado de clusters existentes"
echo -e "   ${CYAN}• Verificar clusters activos${NC}"
echo -e "   ${CYAN}• Estado de despliegues${NC}"
echo ""
echo -e "${GREEN}5)${NC} 🧹 Limpiar despliegues existentes"
echo -e "   ${CYAN}• Eliminar aplicación de un cluster${NC}"
echo -e "   ${CYAN}• Mantener infraestructura${NC}"
echo ""
echo -e "${GREEN}0)${NC} ❌ Salir"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -n -e "${YELLOW}👉 Selecciona una opción [0-5]: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        log_step "Iniciando despliegue en Minikube..."
        echo ""
        
        # Verificar si el script existe
        if [ ! -f "scripts/deploy-minikube.sh" ]; then
            log_error "No se encuentra el script: scripts/deploy-minikube.sh"
            exit 1
        fi
        
        # Dar permisos de ejecución si no los tiene
        chmod +x scripts/deploy-minikube.sh
        
        # Ejecutar script de Minikube
        ./scripts/deploy-minikube.sh
        ;;
    
    2)
        echo ""
        log_step "Iniciando despliegue en Azure AKS..."
        echo ""
        
        # Verificar si el script existe
        if [ ! -f "scripts/deploy-aks.sh" ]; then
            log_error "No se encuentra el script: scripts/deploy-aks.sh"
            exit 1
        fi
        
        # Dar permisos de ejecución si no los tiene
        chmod +x scripts/deploy-aks.sh
        
        # Ejecutar script de Azure AKS
        ./scripts/deploy-aks.sh
        ;;
    
    3)
        echo ""
        log_warning "AWS EKS deployment está en desarrollo"
        log_info "Próximamente disponible..."
        echo ""
        log_info "Por ahora, puedes usar los comandos de AWS CLI manualmente:"
        echo "  aws eks create-cluster --name rancher-eks-cluster --region us-east-1 ..."
        echo ""
        ;;
    
    4)
        echo ""
        log_step "Verificando estado de clusters..."
        echo ""
        
        # Listar contextos de kubectl
        log_info "Contextos disponibles en kubectl:"
        kubectl config get-contexts
        echo ""
        
        # Mostrar contexto actual
        CURRENT_CONTEXT=$(kubectl config current-context)
        log_success "Contexto actual: $CURRENT_CONTEXT"
        echo ""
        
        # Verificar Minikube
        log_info "Estado de Minikube:"
        if command -v minikube &> /dev/null; then
            if minikube status -p k8sLocal &> /dev/null; then
                log_success "Minikube (k8sLocal) está corriendo"
                minikube ip -p k8sLocal || true
            else
                log_warning "Minikube (k8sLocal) no está corriendo"
            fi
        else
            log_warning "Minikube no está instalado"
        fi
        echo ""
        
        # Verificar Azure AKS
        log_info "Clusters de Azure AKS:"
        if command -v az &> /dev/null; then
            if az account show &> /dev/null; then
                az aks list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, Status:powerState.code}" -o table || log_warning "No se encontraron clusters AKS"
            else
                log_warning "No hay sesión activa en Azure CLI (az login)"
            fi
        else
            log_warning "Azure CLI no está instalado"
        fi
        echo ""
        
        # Verificar aplicaciones desplegadas
        log_info "¿Deseas ver el estado de los pods en algún cluster? (s/n)"
        read -r show_pods
        
        if [ "$show_pods" = "s" ]; then
            echo ""
            log_info "Verificando namespace 'microstore' en el cluster actual..."
            if kubectl get namespace microstore &> /dev/null; then
                kubectl get pods -n microstore
                echo ""
                kubectl get svc -n microstore
                echo ""
                kubectl get ingress -n microstore
            else
                log_warning "Namespace 'microstore' no existe en el cluster actual"
            fi
        fi
        ;;
    
    5)
        echo ""
        log_step "Limpieza de despliegues..."
        echo ""
        
        log_warning "Esto eliminará la aplicación MicroStore del cluster actual"
        log_info "La infraestructura del cluster se mantendrá"
        echo ""
        
        CURRENT_CONTEXT=$(kubectl config current-context)
        log_info "Cluster actual: $CURRENT_CONTEXT"
        echo ""
        
        echo -n -e "${YELLOW}¿Estás seguro? [s/n]: ${NC}"
        read -r confirm
        
        if [ "$confirm" = "s" ]; then
            log_info "Eliminando recursos del namespace microstore..."
            
            if kubectl get namespace microstore &> /dev/null; then
                # Eliminar deployments
                kubectl delete deployments --all -n microstore
                
                # Eliminar statefulsets
                kubectl delete statefulsets --all -n microstore
                
                # Eliminar services
                kubectl delete svc --all -n microstore
                
                # Eliminar ingress
                kubectl delete ingress --all -n microstore
                
                # Eliminar configmaps y secrets
                kubectl delete configmaps --all -n microstore
                kubectl delete secrets --all -n microstore
                
                # Eliminar PVCs
                kubectl delete pvc --all -n microstore
                
                # Eliminar namespace
                kubectl delete namespace microstore
                
                log_success "Limpieza completada"
            else
                log_warning "El namespace 'microstore' no existe"
            fi
        else
            log_info "Limpieza cancelada"
        fi
        ;;
    
    0)
        echo ""
        log_info "Saliendo..."
        exit 0
        ;;
    
    *)
        echo ""
        log_error "Opción inválida"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✨ Operación completada${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# Ofrecer ejecutar otra operación
echo -n -e "${YELLOW}¿Deseas realizar otra operación? [s/n]: ${NC}"
read -r repeat

if [ "$repeat" = "s" ]; then
    exec "$0"
fi

echo ""
log_success "¡Hasta luego! 👋"
echo ""
