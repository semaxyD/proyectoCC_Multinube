# 🚀 GUÍA COMPLETA DE DESPLIEGUE - MINIKUBE Y AZURE AKS

## 📋 ÍNDICE
1. [Introducción y Diferencias entre Entornos](#introducción)
2. [Problemas Identificados y Soluciones](#problemas-identificados)
3. [Despliegue en Minikube (Local)](#despliegue-en-minikube)
4. [Despliegue en Azure AKS](#despliegue-en-azure-aks)
5. [Validación y Pruebas](#validación-y-pruebas)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 INTRODUCCIÓN

Este proyecto requiere despliegue en **tres entornos diferentes**:
- **Minikube (Local)**: Cluster Kubernetes local para desarrollo y pruebas
- **Azure AKS**: Cluster Kubernetes en Azure
- **AWS EKS**: Cluster Kubernetes en AWS (documentación separada)

### Diferencias Clave entre Entornos

| Aspecto | Minikube | Azure AKS |
|---------|----------|-----------|
| **Registry de Imágenes** | Local (Minikube) o Docker Hub | Azure Container Registry (ACR) |
| **LoadBalancer** | NodePort o Minikube Tunnel | Azure Load Balancer (IP pública) |
| **Ingress Controller** | Addon de Minikube | NGINX Ingress manual |
| **Almacenamiento** | hostPath o local storage | Azure Disk (Premium_LRS) |
| **ImagePullPolicy** | `Never` o `IfNotPresent` | `Always` (desde ACR) |
| **Acceso Externo** | `minikube service` o tunnel | IP pública automática |

---

## 🔍 PROBLEMAS IDENTIFICADOS Y SOLUCIONES

### 1. **Problema: Referencias de Imágenes Docker**
```yaml
# ❌ PROBLEMA: Placeholder sin reemplazar
image: <TU_REGISTRY>/microstore-frontend:latest
```

**Soluciones:**
- **Minikube**: Usar imágenes locales sin registry prefix
- **AKS**: Reemplazar con ACR login server real

### 2. **Problema: ImagePullPolicy Incorrecto**
```yaml
# ❌ PROBLEMA: Intenta descargar desde registry remoto
imagePullPolicy: Always
```

**Soluciones:**
- **Minikube**: Cambiar a `Never` o `IfNotPresent` para usar imágenes locales
- **AKS**: Mantener `Always` para forzar descarga desde ACR

### 3. **Problema: Namespace "microstore" No Existe**
Los manifiestos asumen que el namespace ya existe, pero no hay archivo para crearlo.

**Solución:** Crear namespace antes de aplicar manifiestos

### 4. **Problema: EXTERNAL_IP Hardcodeado**
```yaml
# k8s/common/configmap.yaml
EXTERNAL_IP: "CHANGE_ME"  # ❌ Nunca se actualiza
```

**Soluciones:**
- **Minikube**: Usar `minikube ip` o configurar tunnel
- **AKS**: Obtener IP del Ingress Controller dinámicamente

### 5. **Problema: Ingress Controller No Instalado**
Los manifiestos de Ingress asumen que el controller existe.

**Soluciones:**
- **Minikube**: Habilitar addon `ingress`
- **AKS**: Instalar NGINX Ingress Controller manualmente

### 6. **Problema: StorageClass No Compatible**
```yaml
# MySQL StatefulSet usa storageClass por defecto
# Puede no ser compatible con Minikube
```

**Soluciones:**
- **Minikube**: Usar `storageClassName: standard` (Minikube default)
- **AKS**: Usar `storageClassName: managed-premium` o default

---

## 🏠 DESPLIEGUE EN MINIKUBE

### Prerequisitos
```bash
# Verificar instalaciones
minikube version
kubectl version --client
docker --version
```

### Paso 1: Iniciar Minikube con Configuración Adecuada
```bash
# Detener Minikube existente si hay problemas
minikube stop -p k8sLocal
minikube delete -p k8sLocal

# Iniciar con recursos suficientes
minikube start -p k8sLocal \
  --cpus=4 \
  --memory=6144 \
  --disk-size=20g \
  --driver=docker \
  --kubernetes-version=v1.28.0

# Verificar
kubectl config use-context k8sLocal
kubectl get nodes
```

### Paso 2: Habilitar Addons Necesarios
```bash
# Habilitar Ingress Controller
minikube addons enable ingress -p k8sLocal

# Habilitar Metrics Server
minikube addons enable metrics-server -p k8sLocal

# Verificar addons
minikube addons list -p k8sLocal
```

### Paso 3: Construir Imágenes Docker Localmente
```bash
# Configurar Docker para usar el daemon de Minikube
eval $(minikube docker-env -p k8sLocal)

# Construir todas las imágenes
cd microProyecto2_CloudComputing

docker build -t microstore-users:latest ./microUsers
docker build -t microstore-products:latest ./microProducts
docker build -t microstore-orders:latest ./microOrders
docker build -t microstore-frontend:latest ./frontend

# Verificar imágenes
docker images | grep microstore

# IMPORTANTE: No cerrar esta terminal o volver a ejecutar eval después
```

### Paso 4: Aplicar Configuración de Minikube
```bash
# Usar el script específico para Minikube (lo crearemos después)
./scripts/deploy-minikube.sh
```

**O manualmente:**

```bash
# 1. Crear namespace
kubectl create namespace microstore

# 2. Aplicar recursos comunes
kubectl apply -f k8s/common/

# 3. Aplicar MySQL
kubectl apply -f k8s/mysql/

# Esperar MySQL
kubectl wait --for=condition=ready pod -l app=mysql -n microstore --timeout=300s

# 4. Aplicar microservicios con imagePullPolicy ajustado
# (Usaremos overlays de Kustomize - ver más adelante)

# 5. Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip -p k8sLocal)
echo "Minikube IP: $MINIKUBE_IP"

# 6. Actualizar ConfigMap con IP real
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$MINIKUBE_IP\"}}"

# 7. Reiniciar frontend para aplicar cambios
kubectl rollout restart deployment/frontend-deployment -n microstore
```

### Paso 5: Acceder a la Aplicación en Minikube

```bash
# Opción 1: Usar minikube service (recomendado)
minikube service frontend-service -n microstore -p k8sLocal

# Opción 2: Port Forwarding
kubectl port-forward svc/frontend-service 5001:80 -n microstore

# Opción 3: Minikube Tunnel (requiere sudo)
# En terminal separada:
minikube tunnel -p k8sLocal
# La aplicación estará en http://localhost/

# Obtener URLs de acceso
echo "Frontend: http://$(minikube ip -p k8sLocal):$(kubectl get svc frontend-service -n microstore -o jsonpath='{.spec.ports[0].nodePort}')"
```

### Paso 6: Verificar Despliegue
```bash
# Ver todos los recursos
kubectl get all -n microstore

# Ver logs
kubectl logs -f deployment/frontend-deployment -n microstore

# Verificar Ingress
kubectl get ingress -n microstore
```

---

## ☁️ DESPLIEGUE EN AZURE AKS

### Prerequisitos
```bash
# Verificar instalaciones
az --version
terraform --version
kubectl version --client

# Login en Azure
az login
az account list --output table
az account set --subscription "TU-SUBSCRIPTION-ID"
```

### Paso 1: Crear Infraestructura con Terraform
```bash
cd microProyecto2_CloudComputing/infra/terraform

# Inicializar Terraform
terraform init

# Revisar plan
terraform plan

# Aplicar (toma 10-15 minutos)
terraform apply

# Guardar outputs importantes
terraform output -raw acr_name
terraform output -raw acr_login_server
terraform output -raw aks_cluster_name
```

### Paso 2: Configurar kubectl para AKS
```bash
# Obtener credenciales del cluster
az aks get-credentials \
  --resource-group rg-microstore-dev \
  --name aks-microstore-cluster \
  --overwrite-existing

# Verificar conexión
kubectl cluster-info
kubectl get nodes
```

### Paso 3: Construir y Subir Imágenes a ACR

**Opción A: Usando el Script (Windows PowerShell)**
```powershell
cd microProyecto2_CloudComputing
.\scripts\build-images.ps1
```

**Opción B: Usando el Script (Linux/Mac)**
```bash
cd microProyecto2_CloudComputing
./scripts/build-images.sh
```

**Opción C: Manual**
```bash
# Obtener nombre del ACR
ACR_NAME=$(terraform -chdir=infra/terraform output -raw acr_name)
ACR_LOGIN_SERVER=$(terraform -chdir=infra/terraform output -raw acr_login_server)

# Login al ACR
az acr login --name $ACR_NAME

# Construir y subir cada imagen
docker build -t $ACR_LOGIN_SERVER/microstore-users:latest ./microUsers
docker push $ACR_LOGIN_SERVER/microstore-users:latest

docker build -t $ACR_LOGIN_SERVER/microstore-products:latest ./microProducts
docker push $ACR_LOGIN_SERVER/microstore-products:latest

docker build -t $ACR_LOGIN_SERVER/microstore-orders:latest ./microOrders
docker push $ACR_LOGIN_SERVER/microstore-orders:latest

docker build -t $ACR_LOGIN_SERVER/microstore-frontend:latest ./frontend
docker push $ACR_LOGIN_SERVER/microstore-frontend:latest

# Verificar
az acr repository list --name $ACR_NAME --output table
```

### Paso 4: Instalar NGINX Ingress Controller
```bash
# Agregar repositorio de Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Instalar NGINX Ingress
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace ingress-nginx \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

# Esperar a que obtenga IP externa (2-5 minutos)
kubectl get svc -n ingress-nginx --watch
```

### Paso 5: Actualizar Manifiestos con ACR
```bash
# Obtener URL del ACR
ACR_LOGIN_SERVER=$(terraform -chdir=infra/terraform output -raw acr_login_server)

# En Linux/Mac:
find k8s -name '*.yaml' -exec sed -i "s|<TU_REGISTRY>|$ACR_LOGIN_SERVER|g" {} +

# En Windows PowerShell:
Get-ChildItem -Path k8s -Filter *.yaml -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace '<TU_REGISTRY>', "$ACR_LOGIN_SERVER" | Set-Content $_.FullName
}

# Verificar cambios
grep -r "azurecr.io" k8s/
```

### Paso 6: Desplegar Aplicación

**Opción A: Script Automático**
```bash
./scripts/deploy.sh
```

**Opción B: Manual**
```bash
# 1. Crear namespace
kubectl create namespace microstore

# 2. Aplicar recursos comunes
kubectl apply -f k8s/common/

# 3. Aplicar MySQL
kubectl apply -f k8s/mysql/
kubectl wait --for=condition=ready pod -l app=mysql -n microstore --timeout=300s

# 4. Aplicar microservicios
kubectl apply -f k8s/users/
kubectl apply -f k8s/products/
kubectl apply -f k8s/orders/
kubectl apply -f k8s/frontend/

# 5. Esperar que estén listos
kubectl wait --for=condition=ready pod -l app=users -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=products -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=orders -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=frontend -n microstore --timeout=180s
```

### Paso 7: Configurar IP Externa
```bash
# Obtener IP del Ingress Controller
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Ingress IP: $INGRESS_IP"

# Actualizar ConfigMap
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$INGRESS_IP\"}}"

# Reiniciar frontend
kubectl rollout restart deployment/frontend-deployment -n microstore
```

### Paso 8: Acceder a la Aplicación
```bash
# Obtener IP del Ingress
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "🌐 Frontend: http://$INGRESS_IP/"
echo "👥 Users API: http://$INGRESS_IP/api/users/"
echo "📦 Products API: http://$INGRESS_IP/api/products/"
echo "📋 Orders API: http://$INGRESS_IP/api/orders/"

# Abrir en navegador
# Windows PowerShell:
Start-Process "http://$INGRESS_IP/"

# Linux:
xdg-open "http://$INGRESS_IP/"

# Mac:
open "http://$INGRESS_IP/"
```

---

## ✅ VALIDACIÓN Y PRUEBAS

### Verificar Estado de Pods
```bash
# Ver todos los recursos
kubectl get all -n microstore

# Debe mostrar:
# - 1 pod MySQL (Running)
# - 2 pods users (Running)
# - 2 pods products (Running)
# - 2 pods orders (Running)
# - 2 pods frontend (Running)
```

### Pruebas de Conectividad
```bash
# Probar APIs desde línea de comandos
# Reemplazar $IP con la IP real

# Frontend
curl http://$IP/

# Users API
curl http://$IP/api/users/ | jq .

# Products API
curl http://$IP/api/products/ | jq .

# Orders API
curl http://$IP/api/orders/ | jq .
```

### Pruebas desde el Navegador
1. Abrir: `http://<EXTERNAL-IP>/`
2. Hacer login con credenciales de prueba:
   - Usuario: `sebas`
   - Password: (ver en `init.sql` - usuarios hasheados)
   - O usuario: `lucia`, password: `pass1`
3. Navegar a:
   - `/users` - Ver lista de usuarios
   - `/products` - Ver lista de productos
   - `/orders` - Ver lista de órdenes

### Verificar Logs
```bash
# Ver logs de cada servicio
kubectl logs -f deployment/frontend-deployment -n microstore
kubectl logs -f deployment/users-deployment -n microstore
kubectl logs -f deployment/products-deployment -n microstore
kubectl logs -f deployment/orders-deployment -n microstore
kubectl logs -f statefulset/mysql -n microstore
```

### Verificar Persistencia de Datos
```bash
# Conectar a MySQL
kubectl exec -it statefulset/mysql -n microstore -- mysql -u root -proot myflaskapp

# Dentro de MySQL:
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;
exit;
```

---

## 🔧 TROUBLESHOOTING

### Problema: Pods en estado ImagePullBackOff

**En Minikube:**
```bash
# Causa: imagePullPolicy incorrecto o imagen no existe localmente
# Solución 1: Reconstruir imágenes con Docker de Minikube
eval $(minikube docker-env -p k8sLocal)
docker build -t microstore-users:latest ./microUsers
# ... repetir para cada servicio

# Solución 2: Cambiar imagePullPolicy a Never
kubectl patch deployment users-deployment -n microstore \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"users","imagePullPolicy":"Never"}]}}}}'
```

**En AKS:**
```bash
# Causa: No se puede descargar desde ACR
# Solución 1: Verificar que la imagen existe
ACR_NAME=$(terraform -chdir=infra/terraform output -raw acr_name)
az acr repository list --name $ACR_NAME

# Solución 2: Verificar permisos ACR-AKS
az aks check-acr --resource-group rg-microstore-dev \
  --name aks-microstore-cluster \
  --acr $ACR_NAME.azurecr.io

# Solución 3: Re-hacer attach
az aks update -n aks-microstore-cluster -g rg-microstore-dev --attach-acr $ACR_NAME
```

### Problema: MySQL Pod No Inicia

```bash
# Ver eventos
kubectl describe pod -l app=mysql -n microstore

# Problema común: PVC no se crea
kubectl get pvc -n microstore

# Solución: Verificar StorageClass
kubectl get storageclass

# En Minikube: Asegurar que 'standard' existe
# En AKS: Asegurar que 'managed-premium' o 'default' existe

# Eliminar y recrear PVC si es necesario
kubectl delete pvc mysql-persistent-storage-mysql-0 -n microstore
kubectl delete pod mysql-0 -n microstore
```

### Problema: Frontend No Conecta con APIs

```bash
# Verificar que EXTERNAL_IP está configurado
kubectl get configmap app-config -n microstore -o yaml

# Si muestra "CHANGE_ME", actualizar:
# Minikube:
MINIKUBE_IP=$(minikube ip -p k8sLocal)
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$MINIKUBE_IP\"}}"

# AKS:
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$INGRESS_IP\"}}"

# Reiniciar frontend
kubectl rollout restart deployment/frontend-deployment -n microstore
```

### Problema: Ingress No Tiene IP Externa

**En Minikube:**
```bash
# Minikube no asigna IP externa real
# Solución: Usar minikube service o tunnel

# Opción 1: Service directo
minikube service frontend-service -n microstore -p k8sLocal

# Opción 2: Tunnel (requiere sudo)
minikube tunnel -p k8sLocal
```

**En AKS:**
```bash
# Esperar más tiempo (hasta 5 minutos)
kubectl get svc ingress-nginx-controller -n ingress-nginx --watch

# Si después de 5 minutos no aparece:
# Verificar cuota de IPs públicas
az network public-ip list --query "[].{Name:name, IP:ipAddress, Location:location}" -o table

# Verificar eventos del servicio
kubectl describe svc ingress-nginx-controller -n ingress-nginx
```

### Problema: Error de Conexión a Base de Datos

```bash
# Verificar que MySQL está running
kubectl get pod -l app=mysql -n microstore

# Verificar logs de MySQL
kubectl logs -f statefulset/mysql -n microstore

# Verificar secrets
kubectl get secret database-secret -n microstore -o yaml

# Decodificar secrets para verificar valores
kubectl get secret database-secret -n microstore -o jsonpath='{.data.DB_HOST}' | base64 -d
kubectl get secret database-secret -n microstore -o jsonpath='{.data.DB_PASSWORD}' | base64 -d

# Probar conexión desde un pod
kubectl run mysql-client --rm -it --image=mysql:8.0 -n microstore -- \
  mysql -h mysql-service -u root -proot myflaskapp
```

### Problema: 502 Bad Gateway en Ingress

```bash
# Causa: Backend no está ready
# Verificar que todos los pods están Running y Ready
kubectl get pods -n microstore

# Verificar endpoints del servicio
kubectl get endpoints -n microstore

# Verificar configuración del Ingress
kubectl describe ingress -n microstore

# Ver logs del Ingress Controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=100
```

### Comandos de Debugging Generales

```bash
# Ver estado detallado de un pod
kubectl describe pod <pod-name> -n microstore

# Ver logs de un pod
kubectl logs <pod-name> -n microstore --tail=100

# Ver logs de contenedor específico (si hay múltiples)
kubectl logs <pod-name> -c <container-name> -n microstore

# Ejecutar shell en un pod
kubectl exec -it <pod-name> -n microstore -- /bin/bash

# Ver eventos del namespace
kubectl get events -n microstore --sort-by='.lastTimestamp'

# Ver uso de recursos
kubectl top nodes
kubectl top pods -n microstore

# Restart de un deployment
kubectl rollout restart deployment/<deployment-name> -n microstore

# Ver historial de rollout
kubectl rollout history deployment/<deployment-name> -n microstore

# Rollback si algo salió mal
kubectl rollout undo deployment/<deployment-name> -n microstore
```

---

## 📚 RESUMEN DE COMANDOS RÁPIDOS

### Minikube - Setup Completo
```bash
# Iniciar
minikube start -p k8sLocal --cpus=4 --memory=6144
minikube addons enable ingress -p k8sLocal
eval $(minikube docker-env -p k8sLocal)

# Build
docker build -t microstore-users:latest ./microUsers
docker build -t microstore-products:latest ./microProducts
docker build -t microstore-orders:latest ./microOrders
docker build -t microstore-frontend:latest ./frontend

# Deploy
./scripts/deploy-minikube.sh

# Access
minikube service frontend-service -n microstore -p k8sLocal
```

### Azure AKS - Setup Completo
```bash
# Infraestructura
cd infra/terraform && terraform apply && cd ../..

# Configurar kubectl
az aks get-credentials --resource-group rg-microstore-dev --name aks-microstore-cluster

# Build y Push
./scripts/build-images.sh

# Deploy
./scripts/deploy.sh

# Access
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

---

## 🎯 SIGUIENTE PASO

Ahora crearemos los scripts específicos para cada entorno que automatizan todo este proceso.
