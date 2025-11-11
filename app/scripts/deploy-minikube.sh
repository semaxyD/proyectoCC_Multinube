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
echo -e "${CYAN}║      🚀 DESPLIEGUE EN MINIKUBE - MICROSTORE                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Variables
PROFILE="k8sLocal"
NAMESPACE="microstore"
MINIKUBE_IP=""

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
        exit 1
    fi
}

# Verificar prerequisitos
log_info "Verificando prerequisitos..."
check_command minikube
check_command kubectl
check_command docker
log_success "Todos los prerequisitos están instalados"

# Verificar que Minikube está corriendo
log_info "Verificando estado de Minikube..."
if ! minikube status -p $PROFILE &> /dev/null; then
    log_error "Minikube no está corriendo con perfil $PROFILE"
    log_info "Iniciando Minikube con configuración recomendada..."
    
    minikube start -p $PROFILE \
        --cpus=4 \
        --memory=6144 \
        --disk-size=20g \
        --driver=docker \
        --kubernetes-version=v1.28.0
    
    log_success "Minikube iniciado correctamente"
else
    log_success "Minikube ya está corriendo"
fi

# Configurar contexto de kubectl
log_info "Configurando contexto de kubectl..."
kubectl config use-context $PROFILE
log_success "Contexto configurado: $PROFILE"

# Verificar nodos
log_info "Verificando nodos del cluster..."
kubectl get nodes
echo ""

# Habilitar addons necesarios
log_info "Habilitando addons de Minikube..."

if ! minikube addons list -p $PROFILE | grep -q "ingress.*enabled"; then
    log_info "Habilitando Ingress addon..."
    minikube addons enable ingress -p $PROFILE
    log_success "Ingress habilitado"
else
    log_success "Ingress ya está habilitado"
fi

if ! minikube addons list -p $PROFILE | grep -q "metrics-server.*enabled"; then
    log_info "Habilitando Metrics Server addon..."
    minikube addons enable metrics-server -p $PROFILE
    log_success "Metrics Server habilitado"
else
    log_success "Metrics Server ya está habilitado"
fi

# Configurar Docker para usar daemon de Minikube
log_info "Configurando Docker para usar daemon de Minikube..."
eval $(minikube docker-env -p $PROFILE)
log_success "Docker configurado para usar daemon de Minikube"

# Verificar si las imágenes ya existen
log_info "Verificando imágenes Docker locales..."
IMAGES_EXIST=true
for image in microstore-users microstore-products microstore-orders microstore-frontend; do
    if ! docker images | grep -q "$image"; then
        IMAGES_EXIST=false
        break
    fi
done

if [ "$IMAGES_EXIST" = false ]; then
    log_warning "Algunas imágenes no existen. Construyendo imágenes Docker..."
    
    # Verificar que estamos en el directorio correcto
    if [ ! -d "microUsers" ] || [ ! -d "frontend" ]; then
        log_error "No estás en el directorio raíz del proyecto"
        log_info "Ejecuta este script desde: microProyecto2_CloudComputing/"
        exit 1
    fi
    
    log_info "Construyendo microstore-users..."
    docker build -t microstore-users:latest ./microUsers
    
    log_info "Construyendo microstore-products..."
    docker build -t microstore-products:latest ./microProducts
    
    log_info "Construyendo microstore-orders..."
    docker build -t microstore-orders:latest ./microOrders
    
    log_info "Construyendo microstore-frontend..."
    docker build -t microstore-frontend:latest ./frontend
    
    log_success "Todas las imágenes construidas exitosamente"
else
    log_success "Todas las imágenes ya existen"
fi

# Listar imágenes construidas
echo ""
log_info "Imágenes disponibles en Minikube:"
docker images | grep microstore

# Crear namespace si no existe
log_info "Creando namespace $NAMESPACE..."
if kubectl get namespace $NAMESPACE &> /dev/null; then
    log_success "Namespace $NAMESPACE ya existe"
else
    kubectl create namespace $NAMESPACE
    log_success "Namespace $NAMESPACE creado"
fi

# Aplicar recursos comunes (secrets y configmaps)
log_info "Aplicando recursos comunes (Secrets y ConfigMaps)..."
kubectl apply -f k8s/common/
log_success "Recursos comunes aplicados"

# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip -p $PROFILE)
log_success "IP de Minikube: $MINIKUBE_IP"

# Actualizar ConfigMap con IP de Minikube
log_info "Actualizando ConfigMap con IP externa de Minikube..."
kubectl patch configmap app-config -n $NAMESPACE \
    -p "{\"data\":{\"EXTERNAL_IP\":\"$MINIKUBE_IP\"}}"
log_success "ConfigMap actualizado con IP: $MINIKUBE_IP"

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

# Crear archivos temporales con imagePullPolicy ajustado para Minikube
log_info "Creando configuración ajustada para Minikube..."

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Función para ajustar deployment YAML
adjust_deployment() {
    local service=$1
    local yaml_file="k8s/${service}/deployment.yaml"
    local temp_file="$TEMP_DIR/${service}-deployment.yaml"
    
    # Copiar y ajustar imagePullPolicy y nombre de imagen
    sed -e 's|image: <TU_REGISTRY>/microstore-|image: microstore-|g' \
        -e 's|image: .*azurecr.io.*/microstore-|image: microstore-|g' \
        -e '/imagePullPolicy/d' \
        "$yaml_file" > "$temp_file"
    
    # Agregar imagePullPolicy: Never después de la línea de imagen
    sed -i '/image: microstore-/a\          imagePullPolicy: Never' "$temp_file"
    
    echo "$temp_file"
}

# Desplegar microservicios
log_info "Desplegando microservicios..."

for service in users products orders; do
    log_info "Desplegando servicio: $service..."
    
    # Ajustar deployment
    adjusted_deployment=$(adjust_deployment $service)
    
    # Aplicar deployment ajustado
    kubectl apply -f "$adjusted_deployment"
    
    # Aplicar service e ingress originales
    kubectl apply -f "k8s/$service/service.yaml"
    kubectl apply -f "k8s/$service/ingress.yaml"
    
    log_success "Servicio $service desplegado"
done

# Desplegar frontend
log_info "Desplegando frontend..."
adjusted_frontend=$(adjust_deployment frontend)
kubectl apply -f "$adjusted_frontend"
kubectl apply -f k8s/frontend/service.yaml
kubectl apply -f k8s/frontend/ingress.yaml
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

# Información de acceso
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "🎯 INFORMACIÓN DE ACCESO"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FRONTEND_NODEPORT=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')

echo -e "${GREEN}📱 Formas de acceder a la aplicación:${NC}"
echo ""
echo -e "${CYAN}1️⃣  Via Minikube Service (RECOMENDADO):${NC}"
echo -e "   ${YELLOW}minikube service frontend-service -n $NAMESPACE -p $PROFILE${NC}"
echo ""
echo -e "${CYAN}2️⃣  Via IP y NodePort:${NC}"
echo -e "   Frontend: ${YELLOW}http://$MINIKUBE_IP:$FRONTEND_NODEPORT${NC}"
echo ""
echo -e "${CYAN}3️⃣  Via Ingress (si está configurado):${NC}"
echo -e "   Frontend: ${YELLOW}http://$MINIKUBE_IP/${NC}"
echo ""
echo -e "${CYAN}4️⃣  Via Port Forwarding:${NC}"
echo -e "   ${YELLOW}kubectl port-forward svc/frontend-service 5001:80 -n $NAMESPACE${NC}"
echo -e "   Luego acceder a: ${YELLOW}http://localhost:5001${NC}"
echo ""

# APIs endpoints
echo -e "${GREEN}🔌 Endpoints de APIs:${NC}"
echo -e "   Users API:    ${YELLOW}http://$MINIKUBE_IP/api/users/${NC}"
echo -e "   Products API: ${YELLOW}http://$MINIKUBE_IP/api/products/${NC}"
echo -e "   Orders API:   ${YELLOW}http://$MINIKUBE_IP/api/orders/${NC}"
echo ""

# Comandos útiles
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "🔧 COMANDOS ÚTILES"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ver logs de un servicio:"
echo "  kubectl logs -f deployment/<service>-deployment -n $NAMESPACE"
echo ""
echo "Abrir dashboard de Minikube:"
echo "  minikube dashboard -p $PROFILE"
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
fi

# Resumen final
echo ""
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "✅ DESPLIEGUE COMPLETADO EN MINIKUBE"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "🚀 Para acceder a la aplicación, ejecuta:"
echo -e "   ${YELLOW}minikube service frontend-service -n $NAMESPACE -p $PROFILE${NC}"
echo ""
log_info "📊 Para ver el dashboard de Minikube:"
echo -e "   ${YELLOW}minikube dashboard -p $PROFILE${NC}"
echo ""
