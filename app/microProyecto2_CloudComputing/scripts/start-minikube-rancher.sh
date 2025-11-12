# Ya tienes todo configurado, ahora construye con ACR Build
export ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

echo "🚀 Construyendo imágenes con ACR Build (sin Docker local)..."

# Construir cada imagen en Azure
az acr build --registry $ACR_NAME --image microstore-users:latest ./microUsers
az acr build --registry $ACR_NAME --image microstore-products:latest ./microProducts
az acr build --registry $ACR_NAME --image microstore-orders:latest ./microOrders
az acr build --registry $ACR_NAME --image microstore-frontend:latest ./frontend

# Verificar que se subieron
az acr repository list --name $ACR_NAME --output table

# Actualizar YAMLs con tu ACR
find k8s -name '*.yaml' -type f -exec sed -i "s|image: microstore-|image: ${ACR_LOGIN_SERVER}/microstore-|g" {} \;
find k8s -name '*.yaml' -type f -exec sed -i "s|imagePullPolicy: Never|imagePullPolicy: Always|g" {} \;

# Verificar cambios
grep "image:" k8s/frontend/deployment.yaml

# Crear namespace
kubectl create namespace microstore

# Aplicar recursos comunes
kubectl apply -f k8s/common/

# Desplegar MySQL
kubectl apply -f k8s/mysql/

# Esperar MySQL (esto puede tardar 2-3 minutos)
echo "⏳ Esperando a que MySQL esté listo..."
kubectl wait --for=condition=ready pod -l app=mysql -n microstore --timeout=300s

# Desplegar microservicios
kubectl apply -f k8s/users/
kubectl apply -f k8s/products/
kubectl apply -f k8s/orders/
kubectl apply -f k8s/frontend/

# Ver estado (presiona Ctrl+C cuando todos estén Running)
kubectl get pods -n microstore --watch#!/bin/bash
set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Iniciando Minikube y reconectando a Rancher...${NC}"

# 1. Iniciar Minikube
echo -e "${BLUE}📦 Iniciando Minikube (perfil k8sLocal)...${NC}"
minikube start -p k8sLocal

# 2. Esperar a que el cluster esté listo
echo -e "${BLUE}⏳ Esperando a que el cluster esté listo...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 3. Verificar si cattle-system existe
echo -e "${BLUE}🔍 Verificando conexión con Rancher...${NC}"
if kubectl get namespace cattle-system &> /dev/null; then
    echo -e "${GREEN}✅ Namespace cattle-system existe${NC}"
    
    # Verificar si los pods están corriendo
    if kubectl get pods -n cattle-system | grep -q "cattle-cluster-agent"; then
        POD_STATUS=$(kubectl get pods -n cattle-system -l app=cattle-cluster-agent -o jsonpath='{.items[0].status.phase}')
        
        if [ "$POD_STATUS" = "Running" ]; then
            echo -e "${GREEN}✅ Agente de Rancher ya está corriendo${NC}"
        else
            echo -e "${YELLOW}⚠️  Agente de Rancher no está corriendo, reiniciando...${NC}"
            kubectl rollout restart deployment cattle-cluster-agent -n cattle-system
        fi
    else
        echo -e "${YELLOW}⚠️  No se encontró el agente de Rancher${NC}"
        echo -e "${BLUE}ℹ️  Necesitas reimportar el cluster a Rancher${NC}"
        echo -e "${BLUE}ℹ️  Ve a Rancher UI → Cluster Management → Import Existing${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Namespace cattle-system no existe${NC}"
    echo -e "${BLUE}ℹ️  Necesitas importar el cluster a Rancher de nuevo:${NC}"
    echo ""
    echo "   1. Ve a Rancher UI: https://52.225.216.248"
    echo "   2. Cluster Management → Import Existing"
    echo "   3. Copia y ejecuta el comando que te proporciona"
    echo ""
fi

# 4. Verificar aplicación MicroStore
echo -e "${BLUE}🛍️  Verificando aplicación MicroStore...${NC}"
if kubectl get namespace microstore &> /dev/null; then
    echo -e "${GREEN}✅ Namespace microstore existe${NC}"
    
    # Verificar pods
    PODS_READY=$(kubectl get pods -n microstore --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    TOTAL_PODS=$(kubectl get pods -n microstore --no-headers 2>/dev/null | wc -l || echo "0")
    
    if [ "$PODS_READY" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
        echo -e "${GREEN}✅ Todos los pods de MicroStore están corriendo ($PODS_READY/$TOTAL_PODS)${NC}"
    else
        echo -e "${YELLOW}⚠️  Algunos pods no están listos ($PODS_READY/$TOTAL_PODS)${NC}"
        kubectl get pods -n microstore
    fi
else
    echo -e "${YELLOW}⚠️  Aplicación MicroStore no está desplegada${NC}"
    echo -e "${BLUE}ℹ️  Para desplegarla: cd /vagrant && kubectl apply -f k8s/${NC}"
fi

# 5. Información final
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Proceso completado${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📊 Estado del cluster:${NC}"
kubectl cluster-info
echo ""
echo -e "${BLUE}🔗 Accesos:${NC}"
echo "   • Rancher: https://52.225.216.248"
echo "   • MicroStore: http://localhost:8080 (después de port-forward)"
echo ""
echo -e "${BLUE}💡 Para acceder a MicroStore:${NC}"
echo "   kubectl port-forward svc/frontend -n microstore 8080:5001 --address='0.0.0.0'"
echo ""
