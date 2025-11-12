# 🎯 GUÍA COMPLETA: RANCHER + VAGRANT + AKS

## 📋 Índice

1. [Arquitectura General](#arquitectura-general)
2. [Ejecución en Vagrant VM](#ejecución-en-vagrant-vm)
3. [Ejecución en Azure AKS](#ejecución-en-azure-aks)
4. [Rancher: El Cerebro Central](#rancher-el-cerebro-central)
5. [Flujo Completo de Despliegue](#flujo-completo-de-despliegue)
6. [Casos de Uso Reales](#casos-de-uso-reales)

---

## 🏗️ Arquitectura General

### Visión Global del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                        TU COMPUTADORA                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    RANCHER SERVER                           │ │
│  │              http://tu-ip-rancher:80                        │ │
│  │                                                              │ │
│  │  Función: Gestión Centralizada de Clusters                 │ │
│  │  - Dashboard web                                            │ │
│  │  - Gestión de usuarios                                      │ │
│  │  - Despliegue de aplicaciones                              │ │
│  │  - Monitoreo de recursos                                    │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Gestiona
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  VAGRANT VM   │    │   AZURE AKS   │    │   AWS EKS    │
│  (Minikube)   │    │   (Cloud)     │    │   (Cloud)    │
│               │    │               │    │              │
│  Tipo: LOCAL  │    │  Tipo: REMOTO │    │ Tipo: REMOTO │
└───────────────┘    └───────────────┘    └──────────────┘
```

### ¿Qué es Rancher?

**Rancher es como un "gerente de edificios" para tus clusters Kubernetes:**

- **Sin Rancher**: Debes conectarte a cada cluster individualmente
  - `kubectl config use-context minikube` → Trabajar en Minikube
  - `kubectl config use-context aks-cluster` → Trabajar en AKS
  - `kubectl config use-context eks-cluster` → Trabajar en EKS

- **Con Rancher**: Un solo dashboard que controla todo
  - Abres el navegador → `http://rancher-ip:80`
  - Ves todos tus clusters en un solo lugar
  - Despliegas a cualquier cluster con un click
  - Comparas recursos entre clusters
  - Monitoreas todo centralizadamente

---

## 🖥️ Ejecución en Vagrant VM

### ¿Qué es la Vagrant VM en este Proyecto?

Tu archivo `Vagrantfile` crea una máquina virtual con:
- **Ubuntu 20.04**
- **Minikube instalado** (Kubernetes local)
- **Docker**
- **kubectl**

Es tu **entorno de desarrollo local** y **cluster de prueba**.

---

### Paso 1: Levantar la Vagrant VM

```bash
# En tu computadora Windows (PowerShell o Git Bash)
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal\microProyecto2_CloudComputing

# Levantar la VM
vagrant up

# Esperar 5-10 minutos (primera vez descarga Ubuntu + Minikube)
```

**¿Qué hace Vagrant aquí?**
- Descarga Ubuntu 20.04
- Crea VM con 4GB RAM, 2 CPUs
- Instala Docker, kubectl, Minikube
- Configura red en `192.168.56.10`

---

### Paso 2: Conectarte a la Vagrant VM

```bash
# SSH a la VM
vagrant ssh

# Ahora estás DENTRO de la VM Ubuntu
# Tu prompt cambia a: vagrant@ubuntu-focal:~$
```

---

### Paso 3: Iniciar Minikube en la VM

```bash
# Dentro de la Vagrant VM
minikube start --driver=docker

# Verificar que funciona
kubectl get nodes
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   1m    v1.28.0
```

**¿Qué acabas de hacer?**
- Minikube crea un cluster Kubernetes **dentro de la VM**
- Usa Docker como "driver" (Kubernetes dentro de contenedores)
- Ahora tienes un cluster K8s funcionando localmente

---

### Paso 4: Desplegar tu Aplicación en Minikube (VM)

#### Opción A: Usar el Script Automatizado (RECOMENDADO)

```bash
# Dentro de la Vagrant VM
cd /vagrant  # Esta carpeta está sincronizada con tu Windows

# Dar permisos
chmod +x quickstart.sh scripts/*.sh

# Ejecutar script
./quickstart.sh
# Seleccionar: [1] Minikube (Local)
```

El script hace automáticamente:
1. ✅ Verifica prerequisitos (kubectl, docker, minikube)
2. ✅ Configura Docker para usar Minikube (`eval $(minikube docker-env)`)
3. ✅ Construye las 4 imágenes Docker localmente
4. ✅ Crea namespace `microstore`
5. ✅ Aplica manifiestos con Kustomize (overlay de Minikube)
6. ✅ Obtiene IP de Minikube y actualiza ConfigMap
7. ✅ Habilita Ingress addon
8. ✅ Muestra URLs de acceso

---

#### Opción B: Manual (Para Entender Cada Paso)

```bash
# Dentro de la Vagrant VM
cd /vagrant

# 1. Configurar Docker para Minikube
eval $(minikube docker-env)
# Esto hace que 'docker build' construya imágenes DENTRO de Minikube

# 2. Construir imágenes
cd frontend && docker build -t microstore-frontend:latest . && cd ..
cd microUsers && docker build -t microstore-users:latest . && cd ..
cd microProducts && docker build -t microstore-products:latest . && cd ..
cd microOrders && docker build -t microstore-orders:latest . && cd ..

# 3. Crear namespace
kubectl create namespace microstore

# 4. Aplicar overlay de Minikube
kubectl apply -k k8s/overlays/minikube

# 5. Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)
echo "IP de Minikube: $MINIKUBE_IP"

# 6. Actualizar ConfigMap con la IP
kubectl patch configmap external-config -n microstore \
  --type merge \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$MINIKUBE_IP\"}}"

# 7. Habilitar Ingress
minikube addons enable ingress

# 8. Esperar a que todos los pods estén listos
kubectl wait --for=condition=ready pod -l app=mysql -n microstore --timeout=300s
kubectl wait --for=condition=ready pod -l app=users -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=products -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=orders -n microstore --timeout=180s
kubectl wait --for=condition=ready pod -l app=frontend -n microstore --timeout=180s

# 9. Ver estado
kubectl get pods -n microstore
```

---

### Paso 5: Acceder a la Aplicación desde Windows

```bash
# Dentro de la VM, obtener la IP de Minikube
minikube ip
# Ejemplo: 192.168.49.2
```

**Desde tu navegador en Windows:**
```
http://192.168.49.2/        → Frontend (dashboard)
http://192.168.49.2/users   → API de usuarios
http://192.168.49.2/products → API de productos
http://192.168.49.2/orders  → API de órdenes
```

**NOTA IMPORTANTE:**
- La IP `192.168.49.2` es la IP **interna de Minikube dentro de la VM**
- Para acceder desde Windows, puedes:
  - **Opción 1**: Usar `minikube service` (port-forward automático)
    ```bash
    # Dentro de la VM
    minikube service frontend -n microstore
    ```
  - **Opción 2**: Configurar port forwarding en Vagrantfile
    ```ruby
    config.vm.network "forwarded_port", guest: 80, host: 8080
    ```
    Luego accedes desde Windows: `http://localhost:8080`

---

## ☁️ Ejecución en Azure AKS

### ¿Qué es AKS en este Proyecto?

**Azure Kubernetes Service (AKS)** es tu cluster Kubernetes en la nube:
- **Gestionado por Azure** (no tienes que mantener el control plane)
- **Escalable** (puedes aumentar/reducir nodos)
- **Alta disponibilidad**
- **Usa Azure Container Registry (ACR)** para almacenar imágenes

---

### Prerequisitos para AKS

```bash
# En tu computadora Windows
# 1. Verificar Azure CLI instalado
az --version

# 2. Login a Azure
az login
# Se abre navegador para autenticarte

# 3. Verificar que tienes acceso a tu subscription
az account show

# 4. Verificar que Terraform ya creó tu infraestructura
cd infra/terraform
terraform output
# Debe mostrar: acr_login_server, aks_cluster_name, resource_group_name
```

---

### Paso 1: Conectar kubectl a AKS

```bash
# En tu computadora Windows (PowerShell)
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal\microProyecto2_CloudComputing

# Obtener credenciales del cluster AKS
az aks get-credentials \
  --resource-group $(cd infra/terraform && terraform output -raw resource_group_name) \
  --name $(cd infra/terraform && terraform output -raw aks_cluster_name)

# Verificar conexión
kubectl config current-context
# Debe mostrar algo como: microstore-aks

kubectl get nodes
# Debe mostrar los nodos de AKS
```

**¿Qué hace esto?**
- Descarga el archivo `kubeconfig` de AKS
- Lo guarda en `~/.kube/config`
- Ahora `kubectl` apunta a AKS en Azure (no a Minikube)

---

### Paso 2: Desplegar en AKS

#### Opción A: Script Automatizado (RECOMENDADO)

```bash
# En tu computadora Windows (Git Bash o WSL)
cd microProyecto2_CloudComputing

# Dar permisos (si usas Git Bash o WSL)
chmod +x quickstart.sh scripts/*.sh

# Ejecutar
./quickstart.sh
# Seleccionar: [2] Azure AKS (Cloud)
```

El script hace:
1. ✅ Verifica Azure CLI autenticado
2. ✅ Lee outputs de Terraform (ACR, AKS)
3. ✅ Login a ACR
4. ✅ Construye y push imágenes a ACR
5. ✅ Instala NGINX Ingress Controller con Helm
6. ✅ Actualiza manifiestos con nombre de ACR
7. ✅ Aplica overlay de Azure
8. ✅ Obtiene IP del LoadBalancer
9. ✅ Actualiza ConfigMap con IP pública
10. ✅ Muestra URLs de acceso

---

#### Opción B: Manual (Para Entender)

```bash
# En PowerShell o Git Bash
cd microProyecto2_CloudComputing

# 1. Obtener nombre del ACR
cd infra/terraform
$ACR_NAME = terraform output -raw acr_login_server
# Ejemplo: microstoreacr123.azurecr.io

# 2. Login a ACR
az acr login --name $ACR_NAME

# 3. Build y Push imágenes a ACR
cd ../..
docker build -t ${ACR_NAME}/microstore-frontend:latest ./frontend
docker push ${ACR_NAME}/microstore-frontend:latest

docker build -t ${ACR_NAME}/microstore-users:latest ./microUsers
docker push ${ACR_NAME}/microstore-users:latest

docker build -t ${ACR_NAME}/microstore-products:latest ./microProducts
docker push ${ACR_NAME}/microstore-products:latest

docker build -t ${ACR_NAME}/microstore-orders:latest ./microOrders
docker push ${ACR_NAME}/microstore-orders:latest

# 4. Instalar NGINX Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

# 5. Crear namespace
kubectl create namespace microstore

# 6. Actualizar manifiestos con nombre de ACR
# Editar k8s/overlays/azure/kustomization.yaml
# Cambiar IMAGE_REGISTRY por tu $ACR_NAME

# 7. Aplicar overlay de Azure
kubectl apply -k k8s/overlays/azure

# 8. Obtener IP del LoadBalancer
kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# Ejemplo: 20.51.34.123

# 9. Actualizar ConfigMap
kubectl patch configmap external-config -n microstore \
  --type merge \
  -p '{"data":{"EXTERNAL_IP":"20.51.34.123"}}'

# 10. Verificar pods
kubectl get pods -n microstore
```

---

### Paso 3: Acceder desde Cualquier Lugar

```bash
# Obtener IP pública
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Acceder desde navegador
http://20.51.34.123/          → Frontend
http://20.51.34.123/users     → API users
http://20.51.34.123/products  → API products
http://20.51.34.123/orders    → API orders
```

**Esta IP es pública**, puedes acceder desde cualquier computadora en el mundo.

---

## 🎛️ Rancher: El Cerebro Central

### ¿Qué Hace Rancher Exactamente?

Rancher **NO ejecuta** tus aplicaciones. Rancher **GESTIONA** tus clusters.

```
┌─────────────────────────────────────────────────────────────┐
│                      RANCHER SERVER                          │
│                   (Corriendo en tu PC)                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              DASHBOARD WEB                          │    │
│  │                                                      │    │
│  │  Clusters Registrados:                              │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │    │
│  │  │ local (VM)   │  │ aks-cluster  │  │ eks-cluster│ │    │
│  │  │ Status: OK   │  │ Status: OK   │  │ Status: OK│  │    │
│  │  │ Nodes: 1     │  │ Nodes: 3     │  │ Nodes: 2  │  │    │
│  │  │ Pods: 15     │  │ Pods: 45     │  │ Pods: 30  │  │    │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │    │
│  │                                                      │    │
│  │  [Deploy App]  [Monitoring]  [Logs]  [Terminal]   │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

### Instalar Rancher (Ya Debería Estar Hecho)

Según tu `INFRASTRUCTURE.md`, Rancher ya está instalado:

```bash
# En tu computadora (donde instalaste Rancher)
docker ps | grep rancher

# Debe mostrar un contenedor corriendo
# rancher/rancher:v2.8.3
```

**Acceder a Rancher:**
```
http://localhost:80
# o
http://TU-IP-LOCAL:80
```

**Primera vez:**
1. Te pedirá crear contraseña de admin
2. Aceptar URL del servidor
3. ¡Listo! Dashboard de Rancher

---

### Registrar Cluster de Vagrant (Minikube) en Rancher

```bash
# 1. En Rancher Web UI
# - Click en "Cluster Management"
# - Click en "Import Existing"
# - Seleccionar "Generic" (importar cualquier Kubernetes)
# - Dar nombre: "local-minikube"
# - Click "Create"

# 2. Rancher te da un comando, algo como:
curl --insecure -sfL https://localhost/v3/import/xxxx.yaml | kubectl apply -f -

# 3. Copiar ese comando
# 4. SSH a tu Vagrant VM
vagrant ssh

# 5. Ejecutar el comando dentro de la VM
curl --insecure -sfL https://TU-IP-RANCHER/v3/import/xxxx.yaml | kubectl apply -f -

# 6. Esperar 1-2 minutos
# 7. En Rancher UI, verás el cluster "local-minikube" aparecer con estado "Active"
```

**¿Qué acabas de hacer?**
- Rancher instaló un "agente" en tu cluster Minikube
- Este agente reporta estado a Rancher cada pocos segundos
- Ahora puedes controlar Minikube desde Rancher UI

---

### Registrar Cluster de AKS en Rancher

```bash
# 1. En Rancher Web UI
# - Click en "Cluster Management"
# - Click en "Import Existing"
# - Seleccionar "Generic"
# - Dar nombre: "azure-aks-prod"
# - Click "Create"

# 2. Rancher te da un comando
curl --insecure -sfL https://localhost/v3/import/yyyy.yaml | kubectl apply -f -

# 3. En tu computadora Windows (con kubectl apuntando a AKS)
kubectl config use-context microstore-aks

# 4. Ejecutar el comando de Rancher
curl --insecure -sfL https://TU-IP-RANCHER/v3/import/yyyy.yaml | kubectl apply -f -

# 5. En Rancher UI, verás "azure-aks-prod" activo
```

---

### Usar Rancher para Gestionar Todo

#### Ver Todos los Clusters

```
Rancher UI → Cluster Management
```

Verás:
- **local-minikube** (Vagrant VM)
  - Nodes: 1
  - CPU: 2 cores
  - RAM: 4GB
  - Pods: 15

- **azure-aks-prod** (Azure)
  - Nodes: 3
  - CPU: 12 cores
  - RAM: 24GB
  - Pods: 45

---

#### Desplegar desde Rancher UI

```
1. Rancher UI → Cluster Explorer
2. Seleccionar cluster (local-minikube o azure-aks-prod)
3. Click en "Apps" → "Charts"
4. O usar "kubectl Shell" directamente en UI
5. O importar tus YAMLs:
   - Workload → Deployments → Import YAML
   - Pegar contenido de k8s/users/deployment.yaml
   - Apply
```

---

#### Comparar Recursos entre Clusters

```
Rancher UI → Cluster Explorer → Select local-minikube
- Ver uso de CPU, RAM, Pods
- Ver eventos

Rancher UI → Cluster Explorer → Select azure-aks-prod
- Ver uso de CPU, RAM, Pods
- Comparar con Minikube
```

---

#### Ver Logs desde Rancher

```
1. Rancher UI → Cluster Explorer → Select cluster
2. Workload → Pods
3. Click en pod "users-xxxxxx"
4. Click en tab "Logs"
5. Ver logs en tiempo real
```

---

#### Abrir Terminal en Pods

```
1. Rancher UI → Cluster Explorer
2. Workload → Pods
3. Click en pod "mysql-0"
4. Click en "Execute Shell"
5. Se abre terminal web dentro del pod
   $ mysql -u root -p
   $ show databases;
```

---

## 🚀 Flujo Completo de Despliegue

### Escenario Real: Desarrollo → Testing → Producción

```
┌─────────────────────────────────────────────────────────────┐
│                    FASE 1: DESARROLLO                        │
│                 (Vagrant VM + Minikube)                      │
└─────────────────────────────────────────────────────────────┘
   │
   │ 1. Levantar VM
   │    vagrant up
   │
   │ 2. SSH a VM
   │    vagrant ssh
   │
   │ 3. Desplegar app
   │    ./quickstart.sh → [1] Minikube
   │
   │ 4. Desarrollar y probar
   │    - Modificar código
   │    - Rebuild imágenes
   │    - kubectl delete pod ... (restart)
   │    - Probar en http://MINIKUBE-IP/
   │
   │ 5. Verificar que funciona
   │    ✅ Todas las APIs responden
   │    ✅ Frontend muestra datos
   │    ✅ CRUD funciona
   │
   ▼
┌─────────────────────────────────────────────────────────────┐
│                    FASE 2: TESTING                           │
│                      (Azure AKS)                             │
└─────────────────────────────────────────────────────────────┘
   │
   │ 1. Conectar kubectl a AKS
   │    az aks get-credentials ...
   │
   │ 2. Desplegar app
   │    ./quickstart.sh → [2] Azure AKS
   │
   │ 3. Probar en entorno cloud
   │    - http://IP-PUBLICA-AKS/
   │    - Verificar performance
   │    - Verificar persistencia (MySQL PVC)
   │
   │ 4. Registrar en Rancher
   │    - Importar cluster AKS a Rancher
   │    - Monitorear desde Rancher UI
   │
   │ 5. Validar escalabilidad
   │    kubectl scale deployment users --replicas=3 -n microstore
   │
   ▼
┌─────────────────────────────────────────────────────────────┐
│                  FASE 3: PRODUCCIÓN                          │
│                     (AWS EKS)                                │
└─────────────────────────────────────────────────────────────┘
   │
   │ (Futuro - similar a AKS pero con AWS)
   │
```

---

### Workflow Diario de Desarrollo

```bash
# MAÑANA - Desarrollo en Minikube (VM)
cd microProyecto2_CloudComputing
vagrant up
vagrant ssh

# Dentro de VM
cd /vagrant
./quickstart.sh  # Seleccionar Minikube

# Modificar código (desde Windows en VSCode)
# Por ejemplo: editar frontend/web/views.py

# Rebuild solo el servicio modificado
eval $(minikube docker-env)
cd frontend
docker build -t microstore-frontend:latest .
cd ..

# Reiniciar pod para usar nueva imagen
kubectl delete pod -l app=frontend -n microstore

# Probar cambios
# http://MINIKUBE-IP/

# TARDE - Desplegar a Testing (AKS)
# Salir de VM
exit

# En Windows
kubectl config use-context microstore-aks
./scripts/deploy-aks.sh

# Verificar en Azure
# http://IP-PUBLICA-AKS/

# Monitorear desde Rancher
# http://localhost:80
# → Cluster Explorer → azure-aks-prod
# → Ver pods, logs, métricas
```

---

## 📊 Casos de Uso Reales

### Caso 1: Debugging en Producción

**Problema**: La API de usuarios falla en AKS pero funciona en Minikube

```bash
# 1. Ver estado en Rancher
Rancher UI → Cluster: azure-aks-prod
→ Workload → Pods → users-xxxx
→ Ver eventos y logs

# 2. Si necesitas más detalle, usar kubectl
kubectl config use-context microstore-aks
kubectl describe pod users-xxxx -n microstore
kubectl logs users-xxxx -n microstore --previous

# 3. Comparar con Minikube
Rancher UI → Cluster: local-minikube
→ Workload → Pods → users-yyyy
→ Comparar configuración

# 4. Verificar diferencias
kubectl config use-context minikube
kubectl get deployment users -n microstore -o yaml > users-minikube.yaml

kubectl config use-context microstore-aks
kubectl get deployment users -n microstore -o yaml > users-aks.yaml

diff users-minikube.yaml users-aks.yaml
```

---

### Caso 2: Escalar Aplicación en Horario Pico

**Situación**: Son las 3pm, esperamos mucho tráfico

```bash
# Opción A: Desde kubectl
kubectl config use-context microstore-aks
kubectl scale deployment frontend --replicas=5 -n microstore
kubectl scale deployment users --replicas=3 -n microstore
kubectl scale deployment products --replicas=3 -n microstore

# Opción B: Desde Rancher UI (más fácil)
Rancher UI → Cluster: azure-aks-prod
→ Workload → Deployments
→ Click en "frontend"
→ Edit → Scale: 5 replicas
→ Save
```

---

### Caso 3: Migrar de Minikube a AKS

**Situación**: Desarrollaste en Minikube, ahora vas a producción

```bash
# 1. Backup de datos de Minikube
kubectl config use-context minikube
kubectl exec -it mysql-0 -n microstore -- mysqldump -u root -prootpassword microstore > backup.sql

# 2. Desplegar infraestructura en AKS
cd infra/terraform
terraform apply

# 3. Desplegar aplicación
cd ../..
./scripts/deploy-aks.sh

# 4. Restaurar datos
kubectl config use-context microstore-aks
kubectl cp backup.sql microstore/mysql-0:/tmp/backup.sql
kubectl exec -it mysql-0 -n microstore -- mysql -u root -prootpassword microstore < /tmp/backup.sql

# 5. Verificar
# http://IP-PUBLICA-AKS/
```

---

### Caso 4: Rollback de Versión Mala

**Situación**: Desplegaste una versión con bug en AKS

```bash
# Opción A: Kubectl
kubectl config use-context microstore-aks
kubectl rollout undo deployment/users -n microstore

# Opción B: Rancher UI
Rancher UI → Cluster: azure-aks-prod
→ Workload → Deployments → users
→ ... → Rollback
→ Seleccionar revisión anterior
```

---

## 🎓 Resumen Ejecutivo

### ¿Dónde Corro Cada Cosa?

| **Qué** | **Dónde** | **Para Qué** |
|---------|-----------|--------------|
| **Vagrant VM** | Tu PC (Windows) | Desarrollo local, pruebas rápidas |
| **Minikube** | Dentro de Vagrant VM | Cluster K8s local |
| **AKS** | Azure Cloud | Testing, staging, producción |
| **Rancher** | Tu PC (Windows) | Gestión centralizada de todo |

---

### ¿Cómo se Relacionan?

```
TU PC (Windows)
├── Rancher (Docker)
│   └── Gestiona todos los clusters
│
├── Vagrant VM (VirtualBox)
│   └── Minikube (Cluster K8s local)
│       └── Aplicación corriendo localmente
│
└── kubectl (CLI)
    ├── Conexión a Minikube (en VM)
    └── Conexión a AKS (en Azure)
```

---

### Comandos Esenciales por Entorno

#### Vagrant/Minikube
```bash
# Levantar VM
vagrant up

# SSH a VM
vagrant ssh

# Dentro de VM: desplegar
cd /vagrant
./quickstart.sh  # → [1] Minikube

# Verificar
minikube ip
# Acceder: http://IP-MINIKUBE/

# Apagar VM
exit
vagrant halt
```

#### Azure AKS
```bash
# En tu PC Windows
# Conectar kubectl
az aks get-credentials --resource-group GRUPO --name CLUSTER

# Desplegar
./quickstart.sh  # → [2] Azure AKS

# Verificar
kubectl get svc -n ingress-nginx
# Acceder: http://IP-PUBLICA/

# Ver logs
kubectl logs -l app=users -n microstore
```

#### Rancher
```bash
# Acceder
http://localhost:80

# Importar cluster (Minikube)
# 1. En VM: kubectl apply -f COMANDO-DE-RANCHER

# Importar cluster (AKS)
# 1. En PC: kubectl config use-context AKS
# 2. En PC: kubectl apply -f COMANDO-DE-RANCHER

# Usar dashboard para todo lo demás
```

---

## 🎯 Recomendaciones

### Para Desarrollo
1. **Usa Vagrant/Minikube** - rápido, gratis, sin consumir créditos Azure
2. **Prueba todo localmente primero** antes de ir a cloud
3. **Usa Rancher local** para practicar gestión multi-cluster

### Para Testing/Producción
1. **Usa AKS** - más estable, escalable, con respaldo
2. **Monitorea desde Rancher** - vista centralizada
3. **Automatiza con scripts** - menos errores humanos

### Para Presentación
1. **Demo en Minikube primero** - no depende de internet
2. **Muestra Rancher** - impresiona con gestión profesional
3. **Backup de AKS** - por si falla internet, tienes Minikube

---

## 📚 Siguientes Pasos

1. **Levantar Vagrant VM**
   ```bash
   vagrant up && vagrant ssh
   ```

2. **Desplegar en Minikube**
   ```bash
   cd /vagrant && ./quickstart.sh
   ```

3. **Registrar en Rancher**
   - Importar cluster Minikube

4. **Desplegar en AKS**
   ```bash
   exit  # Salir de VM
   ./quickstart.sh  # Seleccionar AKS
   ```

5. **Gestionar desde Rancher**
   - Ver ambos clusters
   - Comparar recursos
   - Practicar operaciones

---

## ❓ FAQ

**P: ¿Necesito Rancher para que funcione la aplicación?**
R: NO. La aplicación funciona sin Rancher. Rancher es solo para gestión.

**P: ¿Puedo desplegar en AKS sin usar Vagrant?**
R: SÍ. Vagrant es solo para desarrollo local. AKS es independiente.

**P: ¿Los scripts funcionan en Windows PowerShell?**
R: Los `.sh` necesitan Git Bash o WSL. Los `.ps1` sí funcionan en PowerShell.

**P: ¿Puedo ver Minikube en Rancher si está en la VM?**
R: SÍ, pero necesitas que Rancher pueda alcanzar la IP de la VM (networking).

**P: ¿Cómo cambio entre clusters?**
R: `kubectl config use-context NOMBRE-CONTEXTO`

---

**Creado:** Noviembre 7, 2025  
**Autor:** Guía Completa para MicroStore Multi-Cloud  
**Versión:** 1.0
