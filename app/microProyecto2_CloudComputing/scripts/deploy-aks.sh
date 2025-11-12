#!/bin/bash
set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      ☁️  DESPLIEGUE EN AZURE AKS - MICROSTORE              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Variables
NAMESPACE="microstore"
RESOURCE_GROUP="rg-microstore-dev"
AKS_CLUSTER_NAME="aks-microstore-cluster"
ACR_NAME=""
ACR_LOGIN_SERVER=""
TERRAFORM_DIR="infra/terraform"

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

# Función para verificar comando
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 no está instalado"
        echo "Instálalo antes de continuar"
        exit 1
    fi
}

# Verificar prerequisitos
log_info "Verificando prerequisitos..."
check_command az
check_command kubectl
check_command terraform
check_command docker
log_success "Todos los prerequisitos están instalados"

# Verificar login en Azure
log_info "Verificando sesión de Azure..."
if ! az account show &> /dev/null; then
    log_error "No hay sesión activa en Azure"
    log_info "Por favor ejecuta: az login"
    exit 1
fi

SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
log_success "Sesión activa en Azure"
echo "   Suscripción: $SUBSCRIPTION_NAME"
echo "   ID: $SUBSCRIPTION_ID"
echo ""

# Verificar si la infraestructura está desplegada
log_info "Verificando infraestructura de Azure..."
if [ ! -d "$TERRAFORM_DIR" ]; then
    log_error "No se encuentra el directorio de Terraform: $TERRAFORM_DIR"
    exit 1
fi

if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    log_warning "No se encontró terraform.tfstate"
    log_info "¿La infraestructura ya está desplegada? (s/n)"
    read -r response
    if [ "$response" != "s" ]; then
        log_info "Desplegando infraestructura con Terraform..."
        cd "$TERRAFORM_DIR"
        terraform init
        terraform apply
        cd - > /dev/null
        log_success "Infraestructura desplegada"
    fi
fi

# Obtener información del ACR desde Terraform
log_info "Obteniendo información del Azure Container Registry..."
if [ -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    cd "$TERRAFORM_DIR"
    ACR_NAME=$(terraform output -raw acr_name 2>/dev/null || echo "")
    ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server 2>/dev/null || echo "")
    AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "aks-microstore-cluster")
    RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "rg-microstore-dev")
    cd - > /dev/null
fi

# Si no se pudo obtener del Terraform, pedir manualmente
if [ -z "$ACR_NAME" ]; then
    log_warning "No se pudo obtener ACR desde Terraform"
    echo -n "Ingresa el nombre del Azure Container Registry: "
    read ACR_NAME
    ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
fi

log_success "Azure Container Registry: $ACR_LOGIN_SERVER"
echo ""

# Verificar que el ACR existe
log_info "Verificando acceso al ACR..."
if ! az acr show --name "$ACR_NAME" &> /dev/null; then
    log_error "No se puede acceder al ACR: $ACR_NAME"
    log_info "Verifica que el nombre sea correcto y que tengas permisos"
    exit 1
fi
log_success "ACR accesible"

# Verificar y construir imágenes
log_info "¿Deseas construir y subir las imágenes Docker al ACR? (s/n)"
read -r build_images

if [ "$build_images" = "s" ]; then
    log_info "Construyendo y subiendo imágenes al ACR..."
    
    # Verificar que estamos en el directorio correcto
    if [ ! -d "microUsers" ] || [ ! -d "frontend" ]; then
        log_error "No estás en el directorio raíz del proyecto"
        log_info "Ejecuta este script desde: microProyecto2_CloudComputing/"
        exit 1
    fi
    
    # Login al ACR
    log_info "Haciendo login al ACR..."
    az acr login --name "$ACR_NAME"
    log_success "Login al ACR exitoso"
    
    # Construir y subir cada imagen
    services=("users" "products" "orders" "frontend")
    directories=("microUsers" "microProducts" "microOrders" "frontend")
    
    for i in "${!services[@]}"; do
        service="${services[$i]}"
        directory="${directories[$i]}"
        image_name="$ACR_LOGIN_SERVER/microstore-${service}:latest"
        
        log_info "Construyendo microstore-${service}..."
        docker build -t "$image_name" "./$directory"
        
        log_info "Subiendo microstore-${service} al ACR..."
        docker push "$image_name"
        
        log_success "microstore-${service} subido exitosamente"
    done
    
    log_success "Todas las imágenes construidas y subidas al ACR"
    echo ""
    
    # Verificar imágenes en ACR
    log_info "Imágenes disponibles en ACR:"
    az acr repository list --name "$ACR_NAME" --output table
    echo ""
fi

# Configurar kubectl para AKS
log_info "Configurando kubectl para AKS..."
az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AKS_CLUSTER_NAME" \
    --overwrite-existing

log_success "kubectl configurado para AKS"

# Verificar conexión al cluster
log_info "Verificando conexión al cluster..."
kubectl cluster-info
echo ""

log_info "Nodos del cluster:"
kubectl get nodes -o wide
echo ""

# Verificar/Instalar NGINX Ingress Controller
log_info "Verificando NGINX Ingress Controller..."
if ! kubectl get namespace ingress-nginx &> /dev/null; then
    log_info "Instalando NGINX Ingress Controller..."
    
    # Verificar si Helm está instalado
    if command -v helm &> /dev/null; then
        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
        helm repo update
        helm install ingress-nginx ingress-nginx/ingress-nginx \
            --create-namespace \
            --namespace ingress-nginx \
            --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
        
        log_success "NGINX Ingress Controller instalado"
    else
        log_warning "Helm no está instalado, usando kubectl..."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
        log_success "NGINX Ingress Controller instalado"
    fi
    
    log_info "Esperando que el Ingress Controller obtenga IP externa (puede tardar 2-5 minutos)..."
    sleep 10
else
    log_success "NGINX Ingress Controller ya está instalado"
fi

# Actualizar manifiestos con ACR
log_info "Actualizando manifiestos de Kubernetes con ACR..."

# Crear copias de respaldo
BACKUP_DIR="k8s_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r k8s "$BACKUP_DIR/"
log_success "Backup de manifiestos creado en: $BACKUP_DIR"

# Reemplazar placeholders en archivos YAML
find k8s -name '*.yaml' -type f -exec sed -i "s|<TU_REGISTRY>|$ACR_LOGIN_SERVER|g" {} +
find k8s -name '*.yaml' -type f -exec sed -i "s|image: microstore-|image: $ACR_LOGIN_SERVER/microstore-|g" {} +

log_success "Manifiestos actualizados con ACR"

# Crear namespace si no existe
log_info "Creando namespace $NAMESPACE..."
if kubectl get namespace $NAMESPACE &> /dev/null; then
    log_success "Namespace $NAMESPACE ya existe"
else
    kubectl create namespace $NAMESPACE
    log_success "Namespace $NAMESPACE creado"
fi

# Aplicar recursos comunes
log_info "Aplicando recursos comunes (Secrets y ConfigMaps)..."
kubectl apply -f k8s/common/
log_success "Recursos comunes aplicados"

# Obtener IP del Ingress (puede no estar disponible aún)
log_info "Obteniendo IP del Ingress Controller..."
INGRESS_IP=""
RETRY_COUNT=0
MAX_RETRIES=60

while [ -z "$INGRESS_IP" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -z "$INGRESS_IP" ]; then
        echo -n "."
        sleep 5
        ((RETRY_COUNT++))
    fi
done

echo ""

if [ -z "$INGRESS_IP" ]; then
    log_warning "No se pudo obtener IP del Ingress Controller automáticamente"
    log_info "La aplicación se desplegará, pero deberás actualizar el ConfigMap manualmente después"
    INGRESS_IP="PENDING"
else
    log_success "IP del Ingress Controller: $INGRESS_IP"
    
    # Actualizar ConfigMap con IP real
    log_info "Actualizando ConfigMap con IP externa..."
    kubectl patch configmap app-config -n $NAMESPACE \
        -p "{\"data\":{\"EXTERNAL_IP\":\"$INGRESS_IP\"}}"
    log_success "ConfigMap actualizado"
fi

# Desplegar MySQL
log_info "Desplegando MySQL..."
kubectl apply -f k8s/mysql/
log_success "Manifiestos de MySQL aplicados"

log_info "Esperando que MySQL esté listo (máximo 5 minutos)..."
if kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=300s; then
    log_success "MySQL está listo y funcionando"
else
    log_error "MySQL no pudo iniciarse correctamente"
    log_info "Mostrando información de debug..."
    kubectl get pods -l app=mysql -n $NAMESPACE
    kubectl describe pod -l app=mysql -n $NAMESPACE
    kubectl logs -l app=mysql -n $NAMESPACE --tail=50
    exit 1
fi

# Desplegar microservicios
log_info "Desplegando microservicios..."

for service in users products orders; do
    log_info "Desplegando servicio: $service..."
    kubectl apply -f "k8s/$service/"
    log_success "Servicio $service desplegado"
done

# Desplegar frontend
log_info "Desplegando frontend..."
kubectl apply -f k8s/frontend/
log_success "Frontend desplegado"

# Esperar a que todos los pods estén listos
log_info "Esperando que todos los servicios estén listos..."
echo ""

services=("users" "products" "orders" "frontend")
failed_services=()

for service in "${services[@]}"; do
    log_info "Esperando $service..."
    if kubectl wait --for=condition=ready pod -l app=$service -n $NAMESPACE --timeout=180s; then
        log_success "$service está listo"
    else
        log_warning "$service no está listo después de 3 minutos"
        failed_services+=("$service")
    fi
done

# Mostrar estado del despliegue
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📊 ESTADO DEL DESPLIEGUE"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

log_info "🟢 Pods:"
kubectl get pods -n $NAMESPACE -o wide
echo ""

log_info "🔗 Servicios:"
kubectl get svc -n $NAMESPACE
echo ""

log_info "🌐 Ingress:"
kubectl get ingress -n $NAMESPACE
echo ""

log_info "🚪 Ingress Controller:"
kubectl get svc -n ingress-nginx
echo ""

# Información de acceso
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "🎯 INFORMACIÓN DE ACCESO"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Obtener IP actual (puede haber cambiado)
CURRENT_INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -n "$CURRENT_INGRESS_IP" ]; then
    echo -e "${GREEN}📱 URLs de acceso:${NC}"
    echo ""
    echo -e "   Frontend:     ${YELLOW}http://$CURRENT_INGRESS_IP/${NC}"
    echo -e "   Users API:    ${YELLOW}http://$CURRENT_INGRESS_IP/api/users/${NC}"
    echo -e "   Products API: ${YELLOW}http://$CURRENT_INGRESS_IP/api/products/${NC}"
    echo -e "   Orders API:   ${YELLOW}http://$CURRENT_INGRESS_IP/api/orders/${NC}"
    echo ""
    
    echo -e "${GREEN}🔑 Credenciales de prueba:${NC}"
    echo -e "   Usuario: ${YELLOW}lucia${NC}"
    echo -e "   Password: ${YELLOW}pass1${NC}"
    echo ""
else
    log_warning "El Ingress Controller aún no tiene IP externa asignada"
    log_info "Espera unos minutos y ejecuta:"
    echo "   kubectl get svc ingress-nginx-controller -n ingress-nginx --watch"
    echo ""
    log_info "Una vez que aparezca la IP, actualiza el ConfigMap:"
    echo "   INGRESS_IP=\$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
    echo "   kubectl patch configmap app-config -n $NAMESPACE -p \"{\\\"data\\\":{\\\"EXTERNAL_IP\\\":\\\"\$INGRESS_IP\\\"}}\""
    echo "   kubectl rollout restart deployment/frontend-deployment -n $NAMESPACE"
    echo ""
fi

# Comandos útiles
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "🔧 COMANDOS ÚTILES"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ver logs de un servicio:"
echo "  kubectl logs -f deployment/<service>-deployment -n $NAMESPACE"
echo ""
echo "Ver métricas de recursos:"
echo "  kubectl top nodes"
echo "  kubectl top pods -n $NAMESPACE"
echo ""
echo "Escalar un servicio:"
echo "  kubectl scale deployment/<service>-deployment --replicas=3 -n $NAMESPACE"
echo ""
echo "Reiniciar un deployment:"
echo "  kubectl rollout restart deployment/<service>-deployment -n $NAMESPACE"
echo ""
echo "Ver eventos del namespace:"
echo "  kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
echo ""
echo "Acceder a Azure Portal:"
echo "  az aks browse --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME"
echo ""
echo "Ver logs en Azure Monitor:"
echo "  https://portal.azure.com -> $AKS_CLUSTER_NAME -> Insights"
echo ""

# Mostrar advertencias si hay servicios fallidos
if [ ${#failed_services[@]} -gt 0 ]; then
    echo ""
    log_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_warning "⚠️  ADVERTENCIA: Algunos servicios no están completamente listos"
    log_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    for service in "${failed_services[@]}"; do
        log_warning "Servicio fallido: $service"
        echo "   Debug: kubectl describe pod -l app=$service -n $NAMESPACE"
        echo "   Logs:  kubectl logs -l app=$service -n $NAMESPACE --tail=50"
    done
    echo ""
    log_info "Posibles causas:"
    echo "   • Imágenes no disponibles en ACR"
    echo "   • Errores de configuración"
    echo "   • Problemas de recursos del cluster"
    echo ""
fi

# Resumen de costos
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "💰 GESTIÓN DE COSTOS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_warning "IMPORTANTE: El cluster AKS consume créditos de Azure"
echo ""
echo "Para DETENER el cluster y ahorrar costos:"
echo "  az aks stop --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME"
echo ""
echo "Para INICIAR el cluster nuevamente:"
echo "  az aks start --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME"
echo ""
echo "Para ELIMINAR toda la infraestructura:"
echo "  cd $TERRAFORM_DIR && terraform destroy"
echo ""

# Resumen final
echo ""
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "✅ DESPLIEGUE COMPLETADO EN AZURE AKS"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -n "$CURRENT_INGRESS_IP" ]; then
    log_info "🚀 Tu aplicación está disponible en:"
    echo -e "   ${GREEN}${YELLOW}http://$CURRENT_INGRESS_IP/${NC}"
else
    log_info "⏳ Espera a que el Ingress Controller obtenga una IP externa"
    log_info "   Monitorea con: kubectl get svc -n ingress-nginx --watch"
fi

echo ""
log_info "📊 Para monitoreo y métricas, visita Azure Portal:"
echo -e "   ${CYAN}https://portal.azure.com${NC}"
echo ""
