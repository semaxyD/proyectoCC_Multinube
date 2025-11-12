# Guía de Implementación y Solución de Problemas - Azure AKS# Guía de Despliegue - Azure Kubernetes Service (AKS)



## 📋 Contexto del Proyecto## 📋 Requisitos Previos



Esta guía documenta la **implementación y solución de problemas** realizada en un cluster de Azure Kubernetes Service (AKS) ya existente que presentaba pods en estado **CrashLoopBackOff** debido a errores de configuración.### Cuenta de Azure

- **Suscripción activa** de Azure (Azure for Students o Pay-As-You-Go)

### Información del Cluster- **Azure CLI** instalado localmente O usar **Azure Cloud Shell**

- **Cluster AKS:** `k8s-azure`- **kubectl** instalado (viene preinstalado en Cloud Shell)

- **Resource Group:** `rg-k8s-azure`

- **Región:** `eastus2`### Recursos del Proyecto

- **Azure Container Registry:** `acrk8sazure1762621825.azurecr.io`- **Repositorio Git:** `https://github.com/semaxyD/proyectoCC_Multinube.git`

- **Kubernetes Version:** `v1.33.5`- **Resource Group:** `rg-k8s-azure`

- **Nodos:** 2x Standard_B2s- **Region:** `East US 2`

- **IP Pública:** `20.15.66.143`

---

---

## 🚀 Paso 1: Configurar Azure CLI

## 🔧 Problema 1: Pods en CrashLoopBackOff

### 1.1 Azure Cloud Shell 

### Diagnóstico Inicial

1. Ir a [https://portal.azure.com](https://portal.azure.com)

```bash2. Click en el ícono **Cloud Shell** (>_) en la barra superior

# Verificar estado de pods3. Seleccionar **Bash**

kubectl get pods -n microstore4. Esperar a que se inicialice

---

# Resultado:

# NAME                                   READY   STATUS             RESTARTS   AGE## ☁️ Paso 2: Crear Resource Group

# users-deployment-xxxxx-xxxxx           0/1     CrashLoopBackOff   5          5m

# products-deployment-xxxxx-xxxxx        0/1     CrashLoopBackOff   5          5m```bash

# orders-deployment-xxxxx-xxxxx          0/1     CrashLoopBackOff   5          5m# Definir variables

# frontend-deployment-xxxxx-xxxxx        0/1     CrashLoopBackOff   5          5mRESOURCE_GROUP="rg-k8s-azure"

LOCATION="eastus2"

# Ver logs para identificar el problema

kubectl logs -n microstore users-deployment-xxxxx-xxxxx# Crear resource group

az group create \

# Error encontrado:  --name $RESOURCE_GROUP \

# KeyError: 'MYSQL_HOST'  --location $LOCATION

# El código busca MYSQL_HOST pero el secret tiene DB_HOST

```# Verificar

az group show --name $RESOURCE_GROUP --output table

### Causa Raíz```



- El código de los microservicios usa variables de entorno con el patrón `MYSQL_*` ---

- El secret `database-secret` tenía keys con el patrón `DB_*` (DB_HOST, DB_USER, etc.)

- **Mismatch de nombres** causaba que los pods no pudieran leer las credenciales## 🗄️ Paso 3: Crear Azure Container Registry (ACR)



### Solución: Recrear Secret con Nombres Correctos### 3.1 Crear ACR



```bash```bash

# 1. Eliminar el secret incorrecto# Nombre único del registry (debe ser único globalmente)

kubectl delete secret database-secret -n microstoreACR_NAME="acrk8sazure$(date +%s)"

echo "ACR Name: $ACR_NAME"

# 2. Crear secret con las keys correctas (MYSQL_* en lugar de DB_*)

kubectl create secret generic database-secret -n microstore \# Crear ACR

  --from-literal=MYSQL_HOST=mysql-service \az acr create \

  --from-literal=MYSQL_USER=root \  --resource-group $RESOURCE_GROUP \

  --from-literal=MYSQL_PASSWORD=root \  --name $ACR_NAME \

  --from-literal=MYSQL_DB=microstore \  --sku Basic \

  --from-literal=MYSQL_PORT=3306  --location $LOCATION



# 3. Verificar que las keys sean correctas# Verificar

kubectl describe secret database-secret -n microstoreaz acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --output table

```

# Debe mostrar: MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DB, MYSQL_PORT

### 3.2 Guardar el nombre del ACR

# 4. Reiniciar deployments para que carguen el nuevo secret

kubectl rollout restart deployment users-deployment -n microstore```bash

kubectl rollout restart deployment products-deployment -n microstore# Guardar en variable de entorno (importante para pasos siguientes)

kubectl rollout restart deployment orders-deployment -n microstoreexport ACR_NAME="<tu-acr-name>"

kubectl rollout restart deployment frontend-deployment -n microstore# Ejemplo: export ACR_NAME="acrk8sazure1762621825"

```

# 5. Verificar que los pods estén Running

kubectl get pods -n microstore -w---

```

## ☸️ Paso 4: Crear Cluster AKS

**Resultado:** Todos los pods transicionaron de `CrashLoopBackOff` a `Running 1/1` ✅

### 4.1 Crear el cluster

---

```bash

## 🌐 Problema 2: Ingress No Funciona (404 Errors)# Nombre del cluster

AKS_CLUSTER="k8s-azure"

### Diagnóstico

# Crear cluster AKS (tarda 5-10 minutos)

```bashaz aks create \

# Verificar Ingress  --resource-group $RESOURCE_GROUP \

kubectl get ingress -n microstore  --name $AKS_CLUSTER \

  --node-count 2 \

# Resultado: ADDRESS vacía, no hay IP asignada  --node-vm-size Standard_B2s \

# NAME               CLASS   HOSTS   ADDRESS   PORTS   AGE  --enable-managed-identity \

# frontend-ingress   <none>  *                 80      10m  --generate-ssh-keys \

# users-ingress      <none>  *                 80      10m  --location $LOCATION

# products-ingress   <none>  *                 80      10m

# orders-ingress     <none>  *                 80      10m# Verificar

```az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --output table

```

### Causa Raíz

### 4.2 Conectar kubectl al cluster

- No había **NGINX Ingress Controller** instalado en el cluster

- Los recursos Ingress no tenían `ingressClassName` especificado```bash

- Sin controlador, no se puede enrutar el tráfico externo# Obtener credenciales

az aks get-credentials \

### Solución Parte 1: Instalar NGINX Ingress Controller  --resource-group $RESOURCE_GROUP \

  --name $AKS_CLUSTER \

```bash  --overwrite-existing

# Instalar NGINX Ingress Controller para AKS

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml# Verificar conexión

kubectl get nodes

# Verificar instalación```

kubectl get pods -n ingress-nginx

**Salida esperada:**

# Esperar a que todos los pods estén Running```

kubectl wait --namespace ingress-nginx \NAME                                STATUS   ROLES   AGE   VERSION

  --for=condition=ready pod \aks-default-89644245-vmss000002     Ready    agent   5m    v1.33.5

  --selector=app.kubernetes.io/component=controller \aks-default-89644245-vmss000003     Ready    agent   5m    v1.33.5

  --timeout=120s```

```

### 4.3 Integrar ACR con AKS

### Solución Parte 2: Obtener IP Externa

```bash

```bash# Adjuntar ACR al cluster

# Ver servicio del Ingress Controller (esperar a que se asigne EXTERNAL-IP)az aks update \

kubectl get svc ingress-nginx-controller -n ingress-nginx --watch  --name $AKS_CLUSTER \

  --resource-group $RESOURCE_GROUP \

# Esto crea un Azure Load Balancer y asigna una IP pública  --attach-acr $ACR_NAME

# Puede tardar 2-3 minutos

# Verificar integración

# Una vez asignada, guardar la IPaz aks check-acr \

EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')  --name $AKS_CLUSTER \

echo "IP Externa: $EXTERNAL_IP"  --resource-group $RESOURCE_GROUP \

  --acr ${ACR_NAME}.azurecr.io

# Resultado: 20.15.66.143```

```

---

### Solución Parte 3: Actualizar Ingress con ingressClassName

## 📦 Paso 5: Clonar Repositorio y Construir Imágenes

```bash

# Agregar ingressClassName: nginx a todos los Ingress### 5.1 Clonar el repositorio

kubectl patch ingress frontend-ingress -n microstore \

  --type='json' \```bash

  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'# En Cloud Shell

cd ~

kubectl patch ingress users-ingress -n microstore \git clone https://github.com/Makhai412/proyectoFinalCloudComputing.git

  --type='json' \cd proyectoFinalCloudComputing/microProyecto2_CloudComputing

  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'```



kubectl patch ingress products-ingress -n microstore \### 5.2 Construir imágenes con ACR Build

  --type='json' \

  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'**Nota:** Azure Cloud Shell no tiene Docker daemon, por eso usamos ACR Build



kubectl patch ingress orders-ingress -n microstore \```bash

  --type='json' \# Construir imagen de usuarios

  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'az acr build \

  --registry $ACR_NAME \

# Verificar  --image microstore-users:latest \

kubectl get ingress -n microstore  --file microUsers/Dockerfile \

```  ./microUsers



**Resultado esperado:**# Construir imagen de productos

```az acr build \

NAME               CLASS   HOSTS   ADDRESS         PORTS   AGE  --registry $ACR_NAME \

frontend-ingress   nginx   *       20.15.66.143    80      15m  --image microstore-products:latest \

orders-ingress     nginx   *       20.15.66.143    80      15m  --file microProducts/Dockerfile \

products-ingress   nginx   *       20.15.66.143    80      15m  ./microProducts

users-ingress      nginx   *       20.15.66.143    80      15m

```# Construir imagen de órdenes

az acr build \

✅ **Ingress funcionando con IP pública asignada**  --registry $ACR_NAME \

  --image microstore-orders:latest \

---  --file microOrders/Dockerfile \

  ./microOrders

## 🔄 Problema 3: Error 503 Después de Reiniciar Cluster

# Construir imagen del frontend

### Diagnósticoaz acr build \

  --registry $ACR_NAME \

Después de detener y reiniciar el cluster AKS:  --image microstore-frontend:latest \

  --file frontend/Dockerfile \

```bash  ./frontend

# Acceder a la aplicación```

curl http://20.15.66.143/api/users/

### 5.3 Verificar imágenes

# Error: 503 Service Temporarily Unavailable

``````bash

# Listar imágenes en ACR

```javascriptaz acr repository list --name $ACR_NAME --output table

// En el navegador (Console)

GET http://20.15.66.143/api/users/ 503# Ver tags de una imagen específica

SyntaxError: Unexpected token '<', "<html><h"... is not valid JSONaz acr repository show-tags --name $ACR_NAME --repository microstore-users --output table

``````



### Causa Raíz---



- Los pods de los microservicios no están listos## 🔧 Paso 6: Actualizar Manifiestos de Kubernetes

- El Ingress Controller responde pero no puede enrutar al backend

- Es necesario reiniciar sistemáticamente todos los deployments### 6.1 Actualizar referencias al registry



### Solución: Script de Reinicio Automatizado```bash

# Reemplazar placeholder con nombre real del ACR

**Crear archivo `restart-aks.sh`:**find k8s -name "*.yaml" -type f -exec sed -i "s|<TU_REGISTRY>|${ACR_NAME}.azurecr.io|g" {} +



```bash# Verificar cambios

#!/bin/bashgrep -r "azurecr.io" k8s/*/deployment.yaml

```

echo "🔄 Reiniciando servicios en AKS..."

---

# 1. Reiniciar Ingress Controller

echo "📡 Reiniciando Ingress Controller..."## 🗄️ Paso 7: Desplegar MySQL

kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx

kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=5m### 7.1 Crear namespace



# 2. Reiniciar todos los microservicios```bash

echo "🚀 Reiniciando microservicios..."kubectl create namespace microstore

kubectl rollout restart deployment users-deployment -n microstore```

kubectl rollout restart deployment products-deployment -n microstore

kubectl rollout restart deployment orders-deployment -n microstore### 7.2 Crear secret con credenciales correctas

kubectl rollout restart deployment frontend-deployment -n microstore

```bash

# 3. Esperar a que todos estén listos# IMPORTANTE: Usar MYSQL_* en lugar de DB_*

echo "⏳ Esperando a que los pods estén listos..."kubectl create secret generic database-secret -n microstore \

kubectl wait --for=condition=ready pod -l app=users -n microstore --timeout=5m  --from-literal=MYSQL_HOST=mysql-service \

kubectl wait --for=condition=ready pod -l app=products -n microstore --timeout=5m  --from-literal=MYSQL_USER=root \

kubectl wait --for=condition=ready pod -l app=orders -n microstore --timeout=5m  --from-literal=MYSQL_PASSWORD=root \

kubectl wait --for=condition=ready pod -l app=frontend -n microstore --timeout=5m  --from-literal=MYSQL_DB=microstore \

  --from-literal=MYSQL_PORT=3306

# 4. Verificar IP externa

EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')# Verificar

echo "✅ IP Externa: $EXTERNAL_IP"kubectl describe secret database-secret -n microstore

```

# 5. Probar endpoints

echo "🧪 Probando endpoints..."### 7.3 Desplegar MySQL

curl -s http://$EXTERNAL_IP/api/users/ | head -n 1

curl -s http://$EXTERNAL_IP/api/products/ | head -n 1```bash

# ConfigMap de inicialización

echo "✅ Reinicio completado"kubectl apply -f k8s/mysql/mysql-initdb-configmap.yaml

```

# Secret de MySQL

**Uso:**kubectl apply -f k8s/mysql/secret.yaml



```bash# Servicios

# Hacer ejecutablekubectl apply -f k8s/mysql/headless-service.yaml

chmod +x restart-aks.shkubectl apply -f k8s/mysql/service.yaml



# Ejecutar# StatefulSet

./restart-aks.shkubectl apply -f k8s/mysql/statefulset.yaml

```

# Verificar

**Resultado:** Aplicación accesible nuevamente en `http://20.15.66.143/` ✅kubectl get pods -n microstore -w

# Esperar hasta que mysql-0 esté Running 1/1

---```



## 🐛 Problema 4: Comunicación Entre Microservicios### 7.4 Poblar base de datos (Opcional)



### Diagnóstico```bash

# Conectarse a MySQL

El microservicio de **Orders** necesita comunicarse con **Products** para validar los productos al crear una orden.kubectl exec -it mysql-0 -n microstore -- mysql -u root microstore



```bash# Insertar datos de prueba

# Error en logs del microservicio ordersINSERT INTO users (name, email, username, password) 

kubectl logs -n microstore orders-deployment-xxxxx-xxxxxVALUES ('Admin User', 'admin@microstore.com', 'admin', 

'$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYAZhXXXXXX');

# requests.exceptions.ConnectionError: Failed to establish connection to products service

```INSERT INTO products (name, description, price, stock) 

VALUES ('Laptop Dell XPS 15', 'High performance laptop', 1500.00, 10),

### Causa Raíz       ('Mouse Logitech MX', 'Wireless mouse', 99.99, 50),

       ('Teclado Mecánico', 'RGB keyboard', 149.99, 30);

- El código tenía hardcodeado `http://products:5003` (nombre de pod en lugar de servicio)

- Debía usar el nombre del servicio: `products-service`-- Salir

EXIT;

### Solución: Actualizar Código y Deployment```



**1. Modificar `microOrders/orders/controllers/order_controller.py`:**---



```python## 🚀 Paso 8: Desplegar Microservicios

import os  # Agregar import

### 8.1 ConfigMap común

# Agregar al inicio del archivo

PRODUCTS_SERVICE_URL = os.getenv('PRODUCTS_SERVICE_URL', 'http://localhost:5003')```bash

kubectl apply -f k8s/common/configmap.yaml

# Cambiar las llamadas hardcodeadas```

# ANTES:

# resp = requests.get(f'http://products:5003/api/products/{product_id}')### 8.2 Microservicio de Usuarios



# DESPUÉS:```bash

resp = requests.get(f'{PRODUCTS_SERVICE_URL}/api/products/{product_id}')kubectl apply -f k8s/users/deployment.yaml

```kubectl apply -f k8s/users/service.yaml

kubectl apply -f k8s/users/ingress.yaml

**2. Actualizar `k8s/orders/deployment.yaml`:**

# Verificar

```yamlkubectl get pods -n microstore -l app=users

env:```

  - name: PRODUCTS_SERVICE_URL

    value: "http://products-service"  # Agregar esta variable### 8.3 Microservicio de Productos

  - name: MYSQL_HOST

    valueFrom:```bash

      secretKeyRef:kubectl apply -f k8s/products/deployment.yaml

        name: database-secretkubectl apply -f k8s/products/service.yaml

        key: MYSQL_HOSTkubectl apply -f k8s/products/ingress.yaml

  # ... resto de variables

```# Verificar

kubectl get pods -n microstore -l app=products

**3. Reconstruir imagen y redesplegar:**```



```bash### 8.4 Microservicio de Órdenes

# En Azure Cloud Shell

cd ~/proyectoFinalCloudComputing/microProyecto2_CloudComputing```bash

kubectl apply -f k8s/orders/deployment.yaml

# Reconstruir imagen con ACR Buildkubectl apply -f k8s/orders/service.yaml

az acr build \kubectl apply -f k8s/orders/ingress.yaml

  --registry acrk8sazure1762621825 \

  --image microstore-orders:latest \# Verificar

  --file microOrders/Dockerfile \kubectl get pods -n microstore -l app=orders

  ./microOrders```



# Aplicar cambios al deployment### 8.5 Frontend

kubectl apply -f k8s/orders/deployment.yaml

```bash

# Reiniciar deploymentkubectl apply -f k8s/frontend/deployment.yaml

kubectl rollout restart deployment orders-deployment -n microstorekubectl apply -f k8s/frontend/service.yaml

kubectl apply -f k8s/frontend/ingress.yaml

# Verificar

kubectl get pods -n microstore -l app=orders# Verificar

```kubectl get pods -n microstore -l app=frontend

```

**Resultado:** Orders puede comunicarse con Products a través del servicio ✅

### 8.6 Verificar todos los pods

---

```bash

## 🎯 Integración con Rancherkubectl get pods -n microstore



### Contexto# Todos deben estar en estado Running 1/1

```

Se requería gestionar centralmente ambos clusters (local Minikube y Azure AKS) desde Rancher.

---

- **Rancher Server:** `https://52.225.216.248`

## 🌐 Paso 9: Configurar Ingress Controller

### Pasos de Integración

### 9.1 Instalar NGINX Ingress Controller

**1. Importar cluster en Rancher UI:**

```bash

```# Instalar en AKS (crea un Load Balancer de Azure)

1. Acceder a Rancher: https://52.225.216.248kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

2. Navegar a: ☰ → Cluster Management

3. Click en: Import Existing# Verificar instalación

4. Nombre: k8s-azurekubectl get pods -n ingress-nginx

5. Copiar el comando kubectl apply que aparece

```# Esperar a que todos los pods estén Running

kubectl wait --namespace ingress-nginx \

**2. Ejecutar en Azure Cloud Shell:**  --for=condition=ready pod \

  --selector=app.kubernetes.io/component=controller \

```bash  --timeout=120s

# Pegar el comando copiado de Rancher```

kubectl apply -f https://52.225.216.248/v3/import/xxxxxxxxxxxxxx.yaml

### 9.2 Obtener IP Externa del Load Balancer

# Verificar cattle-system

kubectl get pods -n cattle-system```bash

# Esperar a que se asigne IP externa (puede tardar 2-3 minutos)

# Esperar a que los agentes estén Runningkubectl get svc ingress-nginx-controller -n ingress-nginx --watch

kubectl wait --for=condition=ready pod -n cattle-system --all --timeout=5m

```# Una vez asignada, guardar la IP

EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

**3. Verificar en Rancher UI:**echo "IP Externa: $EXTERNAL_IP"

```

- El cluster `k8s-azure` debe aparecer en la lista

- Estado: **Active** ✅### 9.3 Actualizar Ingress con ingressClassName

- Se puede ver namespace `microstore` con todos los recursos

```bash

**Resultado:** Cluster AKS gestionado desde Rancher ✅# Agregar ingressClassName a todos los Ingress

kubectl patch ingress frontend-ingress -n microstore --type='json' -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'

---

kubectl patch ingress users-ingress -n microstore --type='json' -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'

## 🔄 Reiniciar el Cluster

kubectl patch ingress products-ingress -n microstore --type='json' -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'

### Cuándo Usar

kubectl patch ingress orders-ingress -n microstore --type='json' -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'

- Después de detener el cluster con `az aks stop`

- Al día siguiente de dejarlo sin uso# Verificar

- Cuando los pods no respondenkubectl get ingress -n microstore

```

### Procedimiento Completo

**Salida esperada:**

```bash```

# 1. Iniciar el cluster (si está detenido)NAME               CLASS   HOSTS   ADDRESS         PORTS   AGE

az aks start --name k8s-azure --resource-group rg-k8s-azurefrontend-ingress   nginx   *       20.15.66.143    80      10m

orders-ingress     nginx   *       20.15.66.143    80      10m

# 2. Reconectar kubectlproducts-ingress   nginx   *       20.15.66.143    80      10m

az aks get-credentials \users-ingress      nginx   *       20.15.66.143    80      10m

  --resource-group rg-k8s-azure \```

  --name k8s-azure \

  --overwrite-existing---



# 3. Verificar que los nodos estén listos## ✅ Paso 10: Verificar el Despliegue

kubectl get nodes

### 10.1 Ver todos los recursos

# 4. Ejecutar script de reinicio

./scripts/restart-aks.sh```bash

kubectl get all -n microstore

# 5. Verificar aplicación```

curl http://20.15.66.143/api/users/

```### 10.2 Probar endpoints



---```bash

# Probar usuarios

## ✅ Verificación Finalcurl http://$EXTERNAL_IP/api/users/



### Estado de Recursos# Probar productos

curl http://$EXTERNAL_IP/api/products/

```bash

# Ver todos los recursos# Probar órdenes

kubectl get all -n microstorecurl http://$EXTERNAL_IP/api/orders/



# Resultado esperado:# Probar frontend

# NAME                                      READY   STATUS    RESTARTS   AGEcurl http://$EXTERNAL_IP/

# pod/frontend-deployment-xxxxx-xxxxx       1/1     Running   0          10m```

# pod/mysql-0                               1/1     Running   0          20m

# pod/orders-deployment-xxxxx-xxxxx         1/1     Running   0          10m### 10.3 Acceder desde el navegador

# pod/products-deployment-xxxxx-xxxxx       1/1     Running   0          10m

# pod/users-deployment-xxxxx-xxxxx          1/1     Running   0          10m```bash

```echo "🌐 Aplicación disponible en: http://$EXTERNAL_IP/"

```

### Probar Endpoints

Abre tu navegador y accede a la IP mostrada.

```bash

# Usuarios---

curl http://20.15.66.143/api/users/

# Debe retornar JSON con lista de usuarios## 🎯 Paso 11: Integración con Rancher (Opcional)



# Productos### 11.1 Requisitos

curl http://20.15.66.143/api/products/- Rancher Server desplegado (ejemplo: `https://52.225.216.248`)

# Debe retornar JSON con lista de productos- Acceso de administrador a Rancher



# Frontend### 11.2 Importar cluster a Rancher

curl http://20.15.66.143/

# Debe retornar HTML del dashboard1. **En Rancher UI:**

```   - Navegar a **☰ → Cluster Management**

   - Click en **Import Existing**

### Acceso Web   - Nombre: `k8s-azure`

   - Copiar el comando `kubectl apply`

```

🌐 Aplicación: http://20.15.66.143/2. **En Azure Cloud Shell:**

📊 Usuarios: http://20.15.66.143/api/users/   ```bash

📦 Productos: http://20.15.66.143/api/products/   # Pegar el comando copiado de Rancher

🛒 Órdenes: http://20.15.66.143/api/orders/   kubectl apply -f https://52.225.216.248/v3/import/xxxxx.yaml

```   

   # Verificar cattle-system

---   kubectl get pods -n cattle-system

   ```

## 🛠️ Comandos Útiles para Troubleshooting

3. **Esperar 2-5 minutos** hasta que aparezca como **Active** en Rancher

### Ver Logs

### 11.3 Verificar integración

```bash

# Logs en tiempo real de un microservicioEn Rancher UI:

kubectl logs -n microstore -l app=users -f --tail=50- El cluster `k8s-azure` debe aparecer en la lista

- Estado: **Active** ✅

# Logs de un pod específico- Puedes ver todos los recursos del namespace `microstore`

kubectl logs -n microstore <pod-name> --tail=100

---

# Logs de pod anterior (si crasheó)

kubectl logs -n microstore <pod-name> --previous## 📊 Monitoreo y Logs

```

### Ver logs de un microservicio

### Reiniciar Deployments

```bash

```bash# Ver logs en tiempo real

# Reiniciar un deployment específicokubectl logs -n microstore -l app=users -f --tail=50

kubectl rollout restart deployment users-deployment -n microstore

# Ver logs de un pod específico

# Ver estado del rolloutkubectl logs -n microstore <pod-name> --tail=100

kubectl rollout status deployment users-deployment -n microstore```



# Ver historial de revisiones### Dashboard de Kubernetes (Azure Portal)

kubectl rollout history deployment users-deployment -n microstore

```1. Ir a [portal.azure.com](https://portal.azure.com)

2. Buscar tu cluster AKS: `k8s-azure`

### Describir Recursos3. En el menú lateral: **Kubernetes resources → Workloads**

4. Ver pods, deployments, services, etc.

```bash

# Describir pod (ver eventos y errores)### Métricas con kubectl

kubectl describe pod -n microstore <pod-name>

```bash

# Describir Ingress# Top de nodos

kubectl describe ingress frontend-ingress -n microstorekubectl top nodes



# Describir secret# Top de pods

kubectl describe secret database-secret -n microstorekubectl top pods -n microstore

``````



### Shell en Pod---



```bash## 🔄 Actualizar la Aplicación

# Abrir shell en un pod

kubectl exec -it -n microstore <pod-name> -- /bin/bash### Actualizar código y redesplegar



# Ejecutar comando en pod```bash

kubectl exec -n microstore <pod-name> -- env | grep MYSQL# 1. Hacer cambios en el código local

```# 2. Reconstruir la imagen

az acr build \

### Verificar Variables de Entorno  --registry $ACR_NAME \

  --image microstore-users:latest \

```bash  ./microUsers

# Ver variables de un deployment

kubectl get deployment users-deployment -n microstore -o yaml | grep -A 10 env:# 3. Reiniciar deployment (pull nueva imagen)

kubectl rollout restart deployment users-deployment -n microstore

# Ver secret decodificado

kubectl get secret database-secret -n microstore -o jsonpath='{.data.MYSQL_HOST}' | base64 -d# 4. Monitorear rollout

```kubectl rollout status deployment users-deployment -n microstore



---# 5. Verificar

kubectl get pods -n microstore -l app=users

## 💰 Optimización de Costos```



### Detener el Cluster (Ahorrar ~$30/mes)### Rollback a versión anterior



```bash```bash

# Detener cluster (mantiene configuración y datos)# Ver historial

az aks stop --name k8s-azure --resource-group rg-k8s-azurekubectl rollout history deployment users-deployment -n microstore



# El Load Balancer y ACR siguen cobrando (~$10/mes)# Rollback

```kubectl rollout undo deployment users-deployment -n microstore



### Reiniciar Cluster# Rollback a revisión específica

kubectl rollout undo deployment users-deployment -n microstore --to-revision=2

```bash```

# Iniciar cluster

az aks start --name k8s-azure --resource-group rg-k8s-azure---



# Reconectar kubectl## 🔍 Troubleshooting

az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure

### Problema: Pods en CrashLoopBackOff

# Ejecutar script de reinicio

./scripts/restart-aks.sh```bash

```# Ver logs

kubectl logs -n microstore <pod-name> --previous

### Estimación de Costos

# Describir pod

| Recurso | Costo/Mes | Notas |kubectl describe pod -n microstore <pod-name>

|---------|-----------|-------|

| AKS Control Plane | Gratis | Incluido |# Verificar variables de entorno

| 2x Standard_B2s Nodes | ~$30 | Se puede detener |kubectl exec -n microstore <pod-name> -- env | grep MYSQL

| Load Balancer | ~$5 | Cobra incluso detenido |```

| ACR Basic | ~$5 | Cobra incluso detenido |

| Public IP | ~$3 | Cobra incluso detenido |### Problema: No puedo acceder a la aplicación

| **Total con cluster activo** | **~$43** | |

| **Total con cluster detenido** | **~$13** | Solo infraestructura |```bash

# Verificar Load Balancer

---kubectl get svc -n ingress-nginx



## 📝 Resumen de Soluciones Implementadas# Verificar Ingress

kubectl get ingress -n microstore

| Problema | Causa Raíz | Solución | Resultado |kubectl describe ingress frontend-ingress -n microstore

|----------|-----------|----------|-----------|

| **CrashLoopBackOff** | Mismatch de nombres de variables (DB_* vs MYSQL_*) | Recrear secret con keys correctas | Pods Running ✅ |# Verificar logs del Ingress Controller

| **Ingress 404** | No había Ingress Controller instalado | Instalar NGINX Ingress + agregar ingressClassName | IP pública asignada ✅ |kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50

| **Error 503 después de reinicio** | Pods no listos al reiniciar cluster | Script de reinicio automatizado | Aplicación disponible ✅ |```

| **Orders no comunica con Products** | URL hardcodeada incorrecta | Variable de entorno PRODUCTS_SERVICE_URL | Comunicación exitosa ✅ |

| **Gestión centralizada** | Clusters aislados | Integración con Rancher | Ambos clusters en Rancher ✅ |### Problema: "Unknown database 'myflaskapp'"



---**Causa:** Secret tiene nombre de base de datos incorrecto



## 📚 Referencias**Solución:**

```bash

- [NGINX Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)# Eliminar secret

- [Azure AKS Troubleshooting](https://docs.microsoft.com/en-us/azure/aks/troubleshooting)kubectl delete secret database-secret -n microstore

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

- [Rancher Documentation](https://rancher.com/docs/)# Recrear con datos correctos

kubectl create secret generic database-secret -n microstore \

---  --from-literal=MYSQL_HOST=mysql-service \

  --from-literal=MYSQL_USER=root \

**Autor:** Equipo de Desarrollo Cloud Computing    --from-literal=MYSQL_PASSWORD=root \

**Última actualización:** Noviembre 10, 2025    --from-literal=MYSQL_DB=microstore \

**Versión:** 2.0 (Implementación Real)    --from-literal=MYSQL_PORT=3306

**IP Pública de la Aplicación:** http://20.15.66.143/

# Reiniciar deployments
kubectl rollout restart deployment users-deployment -n microstore
kubectl rollout restart deployment products-deployment -n microstore
kubectl rollout restart deployment orders-deployment -n microstore
```

### Problema: Imágenes no se descargan de ACR

```bash
# Verificar integración ACR-AKS
az aks check-acr \
  --name $AKS_CLUSTER \
  --resource-group $RESOURCE_GROUP \
  --acr ${ACR_NAME}.azurecr.io

# Si falla, re-adjuntar
az aks update \
  --name $AKS_CLUSTER \
  --resource-group $RESOURCE_GROUP \
  --attach-acr $ACR_NAME
```

---

## 💰 Estimación de Costos (Azure for Students)

### Recursos Utilizados

| Recurso | SKU/Tamaño | Costo Aprox. |
|---------|-----------|--------------|
| AKS Control Plane | Managed | **Gratis** |
| VM Nodes (2x) | Standard_B2s | ~$30/mes |
| Load Balancer | Basic | ~$5/mes |
| ACR | Basic | ~$5/mes |
| Public IP | Standard | ~$3/mes |
| **Total Estimado** | | **~$43/mes** |

**Nota:** Con Azure for Students tienes $100 de crédito por 12 meses.

### Optimización de Costos

```bash
# Detener el cluster (mantiene configuración)
az aks stop --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP

# Iniciar nuevamente
az aks start --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP

# Escalar a 0 nodos (ahorra costo de VMs pero Load Balancer sigue activo)
az aks scale \
  --name $AKS_CLUSTER \
  --resource-group $RESOURCE_GROUP \
  --node-count 0
```

---

## 🛑 Limpieza de Recursos

### Eliminar solo el namespace

```bash
kubectl delete namespace microstore
```

### Eliminar el cluster AKS

```bash
az aks delete \
  --name $AKS_CLUSTER \
  --resource-group $RESOURCE_GROUP \
  --yes --no-wait
```

### Eliminar todo el Resource Group

```bash
# ⚠️ CUIDADO: Esto elimina TODO
az group delete \
  --name $RESOURCE_GROUP \
  --yes --no-wait
```

---

## 📊 Arquitectura del Despliegue en Azure

```
┌────────────────────────────────────────────────────────────┐
│                    AZURE CLOUD                             │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │         Resource Group: rg-k8s-azure                 │ │
│  │         Region: East US 2                            │ │
│  │                                                      │ │
│  │  ┌────────────────────────────────────────────────┐ │ │
│  │  │  Azure Container Registry (ACR)                │ │ │
│  │  │  acrk8sazure1762621825.azurecr.io             │ │ │
│  │  │  ┌──────────────────────────────────────────┐ │ │ │
│  │  │  │ Images:                                  │ │ │ │
│  │  │  │ - microstore-users:latest                │ │ │ │
│  │  │  │ - microstore-products:latest             │ │ │ │
│  │  │  │ - microstore-orders:latest               │ │ │ │
│  │  │  │ - microstore-frontend:latest             │ │ │ │
│  │  │  └──────────────────────────────────────────┘ │ │ │
│  │  └────────────────────────────────────────────────┘ │ │
│  │                                                      │ │
│  │  ┌────────────────────────────────────────────────┐ │ │
│  │  │  AKS Cluster: k8s-azure                        │ │ │
│  │  │  Kubernetes: v1.33.5                           │ │ │
│  │  │                                                │ │ │
│  │  │  ┌──────────────────────────────────────────┐ │ │ │
│  │  │  │  Node Pool (Standard_B2s x2)             │ │ │ │
│  │  │  │                                          │ │ │ │
│  │  │  │  Namespace: microstore                   │ │ │ │
│  │  │  │  ┌────────────────────────────────────┐ │ │ │ │
│  │  │  │  │  MySQL StatefulSet                 │ │ │ │ │
│  │  │  │  │  - mysql-0 (Azure Managed Disk)    │ │ │ │ │
│  │  │  │  └────────────────────────────────────┘ │ │ │ │
│  │  │  │                                          │ │ │ │
│  │  │  │  ┌────────────────────────────────────┐ │ │ │ │
│  │  │  │  │  Microservices (2 replicas each)   │ │ │ │ │
│  │  │  │  │  - users-deployment                │ │ │ │ │
│  │  │  │  │  - products-deployment             │ │ │ │ │
│  │  │  │  │  - orders-deployment               │ │ │ │ │
│  │  │  │  │  - frontend-deployment             │ │ │ │ │
│  │  │  │  └────────────────────────────────────┘ │ │ │ │
│  │  │  │                                          │ │ │ │
│  │  │  │  Namespace: ingress-nginx                │ │ │ │
│  │  │  │  ┌────────────────────────────────────┐ │ │ │ │
│  │  │  │  │  NGINX Ingress Controller          │ │ │ │ │
│  │  │  │  └────────────────────────────────────┘ │ │ │ │
│  │  │  └──────────────────────────────────────────┘ │ │ │
│  │  └────────────────────────────────────────────────┘ │ │
│  │                                                      │ │
│  │  ┌────────────────────────────────────────────────┐ │ │
│  │  │  Azure Load Balancer                           │ │ │
│  │  │  Public IP: 20.15.66.143                       │ │ │
│  │  └────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
                    ▲
                    │
         Internet (http://20.15.66.143/)
```

---

## 🔐 Credenciales

### MySQL en AKS
- **Host:** `mysql-service.microstore.svc.cluster.local`
- **Puerto:** `3306`
- **Usuario:** `root`
- **Contraseña:** `root`
- **Base de datos:** `microstore`

### Azure Container Registry
- **Registry:** `<ACR_NAME>.azurecr.io`
- **Autenticación:** Managed Identity (automática desde AKS)

---

## 📝 Comandos de Referencia Rápida

```bash
# Verificar estado general
kubectl get all -n microstore

# Ver logs de todos los pods de un servicio
kubectl logs -n microstore -l app=users --tail=50

# Reiniciar un deployment
kubectl rollout restart deployment <name> -n microstore

# Escalar deployment
kubectl scale deployment users-deployment -n microstore --replicas=3

# Ver eventos
kubectl get events -n microstore --sort-by='.lastTimestamp'

# Shell en un pod
kubectl exec -it -n microstore <pod-name> -- /bin/bash

# Ver configuración de un recurso
kubectl get deployment users-deployment -n microstore -o yaml

# Aplicar cambios
kubectl apply -f k8s/users/deployment.yaml

# Ver costos (en portal)
az consumption usage list --output table
```

---

## 📚 Referencias

- [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/)
- [Azure Container Registry](https://docs.microsoft.com/azure/container-registry/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

**Autor:** Equipo de Desarrollo Cloud Computing  
**Última actualización:** Noviembre 8, 2025  
**Versión:** 1.0  
**IP Pública de la Aplicación:** http://20.15.66.143/
