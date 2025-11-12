# 🏪 MicroStore - Aplicación de Microservicios en Kubernetes

Aplicación de e-commerce basada en microservicios desplegada en múltiples entornos Kubernetes (Local con Minikube y Azure AKS), gestionada centralmente con Rancher.

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=flat&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)](https://www.mysql.com/)

---

## 📋 Descripción del Proyecto

**MicroStore** es una aplicación de comercio electrónico construida con arquitectura de microservicios, desplegada en contenedores y orquestada con Kubernetes. El proyecto demuestra capacidades multi-nube con despliegue local (Minikube) y en la nube (Azure AKS), gestionado centralmente mediante Rancher.

### 🎯 Características Principales

- ✅ Arquitectura de microservicios con Flask
- ✅ Despliegue local con Vagrant + Minikube
- ✅ Despliegue en Azure Kubernetes Service (AKS)
- ✅ Gestión centralizada con Rancher
- ✅ CI/CD con Azure Container Registry
- ✅ Persistencia de datos con MySQL
- ✅ Balanceo de carga con NGINX Ingress
- ✅ Infrastructure as Code (opcional con Terraform)

---

## 🏗️ Arquitectura

### Componentes de la Aplicación

```
┌─────────────────────────────────────────────────────────┐
│                     FRONTEND                            │
│                   (Flask Web UI)                        │
│                  http://<IP>/                           │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              NGINX INGRESS CONTROLLER                   │
│        Enrutamiento: /, /api/users, /api/products      │
└─────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   USERS      │  │  PRODUCTS    │  │   ORDERS     │
│ Microservice │  │ Microservice │  │ Microservice │
│   (Flask)    │  │   (Flask)    │  │   (Flask)    │
│  Port: 5002  │  │  Port: 5003  │  │  Port: 5004  │
└──────────────┘  └──────────────┘  └──────────────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           ▼
                   ┌──────────────┐
                   │    MySQL     │
                   │ StatefulSet  │
                   │ Port: 3306   │
                   └──────────────┘
```

### Microservicios

| Microservicio | Tecnología | Puerto | Descripción |
|---------------|------------|--------|-------------|
| **Frontend** | Flask + Jinja2 | 5001 | Interfaz web de usuario |
| **Users** | Flask + SQLAlchemy | 5002 | Gestión de usuarios y autenticación |
| **Products** | Flask + SQLAlchemy | 5003 | CRUD de productos e inventario |
| **Orders** | Flask + SQLAlchemy | 5004 | Gestión de órdenes de compra |
| **MySQL** | MySQL 8.0 | 3306 | Base de datos relacional |

---

## 🚀 Despliegues Disponibles

### Opción 1: Despliegue Local con Minikube

**⏱️ Tiempo:** 10-15 minutos  
**💰 Costo:** Gratis  
**📖 Guía:** [DEPLOYMENT-LOCAL-MINIKUBE.md](./DEPLOYMENT-LOCAL-MINIKUBE.md)

```bash
# 1. Clonar repositorio
git clone https://github.com/Makhai412/proyectoFinalCloudComputing.git
cd proyectoFinalCloudComputing/microProyecto2_CloudComputing

# 2. Iniciar VM con Vagrant
vagrant up

# 3. Conectarse y desplegar
vagrant ssh
minikube start --driver=docker --memory=3000 --cpus=2
kubectl apply -f k8s/

# Acceso: http://192.168.56.10/
```

### Opción 2: Despliegue en Azure AKS

**⏱️ Tiempo:** 30-40 minutos  
**💰 Costo:** ~$43/mes (Azure for Students: $100 crédito)  
**📖 Guía:** [DEPLOYMENT-AZURE-AKS.md](./DEPLOYMENT-AZURE-AKS.md)

```bash
# 1. Crear infraestructura
az group create --name rg-k8s-azure --location eastus2
az aks create --resource-group rg-k8s-azure --name k8s-azure --node-count 2

# 2. Construir y desplegar
az acr build --registry $ACR_NAME --image microstore-users:latest ./microUsers
kubectl apply -f k8s/

# Acceso: http://<EXTERNAL_IP>/
```

---

## 📦 Requisitos Previos

### Para Despliegue Local

| Software | Versión | Propósito |
|----------|---------|-----------|
| VirtualBox | 6.1+ | Hipervisor |
| Vagrant | 2.2+ | Automatización de VM |
| Git | 2.x | Control de versiones |

**Recursos:** RAM 8GB (4GB para VM), CPU 4 cores, 20GB disco

### Para Despliegue en Azure

| Herramienta | Descripción |
|-------------|-------------|
| Azure CLI | CLI de Azure |
| Azure Cloud Shell | Terminal en navegador (recomendado) |
| kubectl | Cliente Kubernetes |
| Cuenta Azure | Suscripción activa |

---

## 🎯 Gestión con Rancher

Ambos clusters pueden ser gestionados centralmente desde Rancher:

```bash
# 1. Acceder a Rancher UI
https://52.225.216.248

# 2. Importar cluster: Cluster Management → Import Existing
# 3. Copiar comando y ejecutar en cada cluster

# Verificar conexión
kubectl get pods -n cattle-system
```

**Resultado:** Clusters visibles en Rancher con estado **Active** ✅

---

## ✅ Verificación

### Estado de Pods

```bash
kubectl get pods -n microstore

# Esperado:
# NAME                                   READY   STATUS    RESTARTS   AGE
# frontend-deployment-xxxxx-xxxxx        1/1     Running   0          5m
# mysql-0                                1/1     Running   0          10m
# orders-deployment-xxxxx-xxxxx          1/1     Running   0          5m
# products-deployment-xxxxx-xxxxx        1/1     Running   0          5m
# users-deployment-xxxxx-xxxxx           1/1     Running   0          5m
```

### Probar Endpoints

```bash
# Local
curl http://192.168.56.10/api/users/

# Azure
curl http://$EXTERNAL_IP/api/users/
```

---

## 📊 Comparación de Despliegues

| Característica | Minikube Local | Azure AKS |
|----------------|----------------|-----------|
| **Tiempo Setup** | 10-15 min | 30-40 min |
| **Costo** | Gratis | ~$43/mes |
| **Escalabilidad** | Limitada (1 nodo) | Auto-scaling (1-5 nodos) |
| **Persistencia** | Local | Azure Managed Disk |
| **IP Pública** | No (solo local) | Sí (Load Balancer) |
| **Monitoreo** | kubectl | Container Insights |
| **Backup** | Manual | Automático |
| **Ideal para** | Desarrollo | Producción/Demo |

---

## 🛠️ Comandos Útiles

### Kubernetes

```bash
# Ver todos los recursos
kubectl get all -n microstore

# Ver logs en tiempo real
kubectl logs -f deployment/users-deployment -n microstore

# Reiniciar deployment
kubectl rollout restart deployment users-deployment -n microstore

# Shell en un pod
kubectl exec -it deployment/users-deployment -n microstore -- /bin/bash
```

### Vagrant (Local)

```bash
vagrant up       # Iniciar VM
vagrant ssh      # Conectarse
vagrant halt     # Detener
vagrant destroy  # Eliminar
```

### Azure

```bash
# Detener cluster (ahorrar costos)
az aks stop --name k8s-azure --resource-group rg-k8s-azure

# Reiniciar cluster
az aks start --name k8s-azure --resource-group rg-k8s-azure

# Ver imágenes en ACR
az acr repository list --name $ACR_NAME
```

---

## 🐛 Troubleshooting

### Pods en CrashLoopBackOff

```bash
kubectl logs -n microstore <pod-name> --previous
kubectl rollout restart deployment <name> -n microstore
```

### Error 503 al acceder

```bash
# Local: Verificar Ingress
minikube addons enable ingress

# Azure: Reiniciar servicios
./scripts/restart-aks.sh
```

### MySQL no conecta

```bash
# Recrear secret con credenciales correctas
kubectl delete secret database-secret -n microstore
kubectl create secret generic database-secret -n microstore \
  --from-literal=MYSQL_HOST=mysql-service \
  --from-literal=MYSQL_USER=root \
  --from-literal=MYSQL_PASSWORD=root \
  --from-literal=MYSQL_DB=microstore \
  --from-literal=MYSQL_PORT=3306
```

---

## 📁 Estructura del Proyecto

```
microProyecto2_CloudComputing/
├── frontend/                      # Microservicio Frontend (Flask)
├── microUsers/                    # Microservicio de Usuarios
├── microProducts/                 # Microservicio de Productos
├── microOrders/                   # Microservicio de Órdenes
├── k8s/                          # Manifiestos Kubernetes
│   ├── common/                   # Secrets, ConfigMaps
│   ├── mysql/                    # MySQL StatefulSet
│   ├── users/                    # Deployment, Service, Ingress
│   ├── products/
│   ├── orders/
│   └── frontend/
├── scripts/                      # Scripts de automatización
│   ├── start-minikube-rancher.sh # Iniciar local
│   ├── restart-aks.sh           # Reiniciar AKS
│   └── build-images.sh          # Construir imágenes
├── Vagrantfile                   # Configuración VM local
├── DEPLOYMENT-LOCAL-MINIKUBE.md  # Guía despliegue local
├── DEPLOYMENT-AZURE-AKS.md       # Guía despliegue Azure
└── README.md                     # Este archivo
```

---

## 📊 Estimación de Costos (Azure)

| Recurso | Configuración | Costo/Mes |
|---------|---------------|-----------|
| AKS Control Plane | Managed | **Gratis** |
| Nodos (2x) | Standard_B2s | ~$30 |
| Load Balancer | Basic | ~$5 |
| ACR | Basic | ~$5 |
| Public IP | Standard | ~$3 |
| **TOTAL** | | **~$43** |

💡 **Azure for Students:** $100 crédito por 12 meses

---

## 👥 Equipo

Proyecto desarrollado para el curso de **Computación en la Nube - 2025**

| Nombre | Rol | Responsabilidades |
|--------|-----|-------------------|
| **Sebastian Marinez** | DevOps Engineer | Infraestructura y automatización |
| **Andres Higuera** | Backend Developer | Despliegue de microservicios |
| **Nicolas Gonzales** | Network Engineer | Load Balancer e Ingress |
| **Santiago Cortes** | SRE | Monitoreo con Rancher |

---

## 📚 Referencias

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/)
- [Rancher Documentation](https://rancher.com/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---

## 🤝 Contribución

1. Fork el repositorio
2. Crear rama: `git checkout -b feature/AmazingFeature`
3. Commit: `git commit -m 'Add AmazingFeature'`
4. Push: `git push origin feature/AmazingFeature`
5. Abrir Pull Request

---

## ⭐ Agradecimientos

Si este proyecto te fue útil, considera darle una ⭐ en GitHub!

---

**Última actualización:** Noviembre 10, 2025  
**Versión:** 1.0  
**Repositorio:** [github.com/Makhai412/proyectoFinalCloudComputing](https://github.com/Makhai412/proyectoFinalCloudComputing)
