# Proyecto Multinube - Infraestructura Kubernetes

Proyecto de infraestructura multinube con Kubernetes, gestionado centralmente con Rancher.

> ⚠️ **Nota sobre AWS EKS**: Inicialmente se contempló incluir un cluster EKS de AWS, pero debido a limitaciones de AWS Academy (créditos insuficientes y restricciones de permisos del LabRole que impedían el despliegue de aplicaciones), se decidió excluirlo del proyecto. La infraestructura final consta de **Azure AKS** (nube pública) y **Minikube** (ambiente local), ambos gestionados con Rancher.

## 🚀 Inicio Rápido

### Resumen de Pasos Principales

```bash
# 1. Aprovisionar infraestructura Azure con Terraform
cd terraform/azure/rancher-server && terraform init && terraform apply
cd ../aks-cluster && terraform init && terraform apply

# 2. Crear VM local con Vagrant
cd ../../local && vagrant up

# 3. Configurar Rancher y registrar clusters desde UI
# Rancher UI → Import Existing → Copiar comando → Ejecutar en cada cluster
```

> 📖 **Ver guía completa paso a paso**: [`QUICK_START.md`](./QUICK_START.md) (~30-35 minutos total)
> 
> 💡 **Nota**: El paso 3 es manual. Ver secciones detalladas abajo.

---

## 🏗️ Arquitectura

### Componentes Principales

1. **Rancher Server** (Azure)
   - Panel de gestión centralizado
   - Versión: v2.8.3
   - Gestiona clusters de Azure y Local

2. **Cluster AKS** (Azure Kubernetes Service)
   - 2 nodos `Standard_B2s`
   - Ubuntu 22.04 LTS
   - Integrado con Azure Monitor
   - Aplicación MicroStore desplegada

3. **Cluster Local** (Minikube)
   - Entorno de desarrollo local
   - 2 vCPU, 4GB RAM
   - Desplegado en VM Ubuntu 22.04 con Vagrant
   - Aplicación MicroStore desplegada

## 📁 Estructura del Proyecto

```
.
├── terraform/
│   ├── azure/                    # Infraestructura Azure (AUTOMATIZADO)
│   │   ├── rancher-server/       # VM Rancher
│   │   └── aks-cluster/          # Cluster AKS
│   └── local/                    # VM local con Vagrant (AUTOMATIZADO)
│       ├── Vagrantfile          # Configuración VM VirtualBox
│       └── README.md
├── scripts/                      # Scripts manuales de ayuda
│   ├── rancher-setup.sh         # Instalación Rancher (usado por Terraform)
│   ├── create-k8sLocal.sh       # Creación cluster local (usado por Vagrant)
│   └── register-cluster.sh      # Registro de clusters (MANUAL)
├── app/                          # Aplicación MicroStore
│   └── microProyecto2_CloudComputing/
│       ├── microUsers/          # Microservicio de usuarios
│       ├── microProducts/       # Microservicio de productos
│       ├── microOrders/         # Microservicio de órdenes
│       ├── frontend/            # Frontend web
│       └── k8s/                 # Manifiestos Kubernetes
└── docs/                         # Documentación adicional
    └── troubleshooting.md
```

### ⚙️ ¿Qué es automático y qué es manual?

| Componente | Método | Automatización |
|-----------|--------|----------------|
| **Rancher Server** | Terraform + cloud-init | ✅ Totalmente automático |
| **AKS Cluster** | Terraform | ✅ Totalmente automático |
| **VM Local (Vagrant)** | Vagrant + script | ✅ Automático con `vagrant up` |
| **Registro en Rancher** | UI de Rancher | ❌ Manual (más simple que API) |
| **Despliegue App** | kubectl + manifiestos | ❌ Manual (ver guías específicas) |

## 🚀 Requisitos Previos

### Herramientas Necesarias

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://www.vagrantup.com/) (para cluster local)

### Credenciales

- **Azure**: Suscripción activa (Azure for Students - $100 crédito)
- **Local**: VirtualBox instalado (gratis)

## 📋 Guía de Despliegue

### Paso 1: Infraestructura Azure con Terraform

#### 1.1 Rancher Server

```bash
cd terraform/azure/rancher-server
terraform init
terraform plan
terraform apply
```

Esto desplegará **automáticamente**:
- Resource Group: `rg-rancher-server`
- VM Ubuntu 22.04 con Docker y Rancher v2.8.3
- Networking y Security Groups configurados

#### 1.2 Cluster AKS

```bash
cd terraform/azure/aks-cluster
terraform init
terraform plan
terraform apply
```

Esto desplegará:
- Resource Group: `rg-k8s-azure`
- Cluster AKS con 2 nodos
- Configuración de red y monitoreo

### Paso 2: Configuración de Rancher

1. Obtener IP pública de Rancher:
   ```bash
   terraform output rancher_public_ip
   ```

2. Acceder a `https://<RANCHER_IP>`

3. Obtener password inicial:
   ```bash
   ssh -i ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>
   sudo docker logs <container_id> 2>&1 | grep "Bootstrap Password:"
   ```

4. Configurar password: `proyectoCCG1`

### Paso 3: Registrar Cluster AKS en Rancher

#### 3.1 Obtener credenciales del cluster
```bash
az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure
```

#### 3.2 Registrar en Rancher UI

1. Acceder a Rancher: `https://<RANCHER_IP>`
2. Ir a **Clusters** → **Import Existing**
3. Seleccionar **"Generic"**
4. Nombrar el cluster: `k8s-azure`
5. Agregar descripción (opcional)
6. Click **"Create"**

#### 3.3 Aplicar configuración de Rancher

Copiar el comando proporcionado por Rancher y ejecutarlo en tu terminal:

```bash
# Asegurarse de estar en el contexto correcto
kubectl config current-context

# Ejecutar comando de Rancher (ejemplo)
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -

# Verificar registro
kubectl get namespace cattle-system
kubectl get pods -n cattle-system
```

**En Rancher UI**, el cluster debe aparecer como **Active** en 2-3 minutos.

---

### Paso 4: Cluster Local con Vagrant + Minikube

#### 4.1 Crear VM y cluster

> ℹ️ **Automatizado con Vagrant**: El script `create-k8sLocal.sh` se ejecuta automáticamente.

```bash
# Crear VM y cluster automáticamente
cd terraform/local
vagrant up

# Verificar cluster
vagrant ssh -c "kubectl get nodes"
```

#### 4.2 Registrar en Rancher

1. Acceder a Rancher UI: `https://<RANCHER_IP>`
2. **Clusters** → **Import Existing** → **Generic**
3. Nombrar el cluster: `k8sLocal`
4. Copiar comando proporcionado

5. Ejecutar dentro de la VM:
```bash
vagrant ssh

# Ejecutar comando de Rancher (ejemplo)
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -

# Verificar registro
kubectl get pods -n cattle-system
```

## 🔧 Configuración Post-Instalación

### Solución de Problema de IP Dinámica (Rancher)

Si la IP de Rancher cambia al reiniciar:

**Windows** (`C:\Windows\System32\drivers\etc\hosts`):
```
<IP_PUBLICA> rancher.local
```

**Linux/Mac** (`/etc/hosts`):
```
<IP_PUBLICA> rancher.local
```

Acceder vía: `https://rancher.local`

## 📊 Verificación

### Verificar clusters registrados

En Rancher UI:
- Todos los clusters deben aparecer con estado **Active**
- Los nodos deben estar **Ready**

### Verificar con kubectl

```bash
# Listar contextos
kubectl config get-contexts

# Cambiar a un cluster específico
kubectl config use-context k8s-azure

# Ver nodos
kubectl get nodes -o wide
```
### Configuracion del balanceador de carga en rancher atraves de la UI

Dentro de la UI de rancher nos dirigimos al cluster manager y seleccionamos el cluster donde pondremos el servicio de balanceo, para esta guia se elige k8s-azure ya que es el disponible este momento.

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/358af0c3-ecae-44d8-8a81-54949e87596b" />

Ya adentro se selecciona un nodo. 

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/12972c67-05e5-42ed-b303-d9834583b50e" />

Dentro de de la configuracion del node vamos hacia services dentro del desplegable de services discovery.

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/be83038c-dfe9-4762-b4b5-da6549d15277" />

Luego le damos click a create.

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/e494689f-709f-4d0c-b747-a9edb9e38959" />

Buscamos el tipo de servicio Load Balancer.

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/4897810d-53e6-4205-ab50-68d4518b2b5a" />

En esta interfaz nos dara a elegir el namespace donde queremos el servicio en este caso microstore, le ponemos un nombre al servicio aqui se le puso balanceador y agregamos unos puertos donde para el ejemplo se puso el 80 y el nombre del puerto llamado http. Para la configuracion de ip addres es recomendable poner la ip del balanceador en el rango de la ip del nodo donde se encuentra para el ejemplo fue 192.168.49.1.

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/a4333d68-6b67-4062-a612-feb89f40b6be" />

<img width="1366" height="618" alt="image" src="https://github.com/user-attachments/assets/33a1d3ba-42dc-40c8-9eaa-265d64656a24" />

Nota: el cluster ip y node port se autogeneran, no es necesario poner valores ahi.

ya por ultimo si no quieres realizar modificaciones adicionales debes crear el balanceador dandole al boton de crear. Puedes probar haciendo curl desde la cli hacia la ip del balanceador y el puerto abierto.

## 🛠️ Comandos Útiles

### Terraform

```bash
# Ver outputs
terraform output

# Destruir infraestructura
terraform destroy

# Formatear archivos
terraform fmt -recursive

# Validar configuración
terraform validate
```

### Clusters

```bash
# Ver todos los nodos de todos los clusters
kubectl get nodes --all-namespaces

# Ver pods de cattle-system (agentes Rancher)
kubectl get pods -n cattle-system

# Logs de un pod
kubectl logs -f <pod-name> -n cattle-system
```

---

## ✅ Checklist de Despliegue Completo

### 📦 Aprovisionamiento Automático (con Terraform/Vagrant)

- [ ] **Rancher Server**: `cd terraform/azure/rancher-server && terraform apply`
- [ ] **Cluster AKS**: `cd terraform/azure/aks-cluster && terraform apply`
- [ ] **VM Local**: `cd terraform/local && vagrant up`

### 🔧 Configuración Manual

- [ ] **Configurar Rancher**: Acceder a `https://<RANCHER_IP>`, obtener bootstrap password, configurar password permanente
- [ ] **Registrar AKS en Rancher**: UI → Import → Ejecutar comando en AKS
- [ ] **Registrar k8sLocal en Rancher**: UI → Import → Ejecutar comando en VM
- [ ] **Desplegar Aplicación MicroStore**: Ver guías en `app/microProyecto2_CloudComputing/`

### ✔️ Verificación

- [ ] Ambos clusters (AKS y k8sLocal) aparecen como **Active** en Rancher UI
- [ ] Todos los nodos muestran estado **Ready**
- [ ] Pods de `cattle-system` están **Running** en cada cluster
- [ ] Aplicación accesible en AKS: `http://20.15.66.143/`
- [ ] Aplicación accesible localmente: `http://192.168.56.10/`

---

## 🐛 Troubleshooting

Ver guía completa en: [`docs/troubleshooting.md`](./docs/troubleshooting.md)

### Problemas Comunes

1. **Rancher no accesible**: Verificar Security Groups y que el contenedor esté `healthy`
2. **Cluster no se registra**: Verificar conectividad de red y certificados SSL
3. **Nodos NotReady**: Verificar recursos (CPU/RAM) y logs de kubelet

## 📚 Documentación Adicional

### Guías de Infraestructura

- 📖 [Guía de Inicio Rápido](./QUICK_START.md) - Despliega infraestructura en 30 minutos
- 🔧 [Rancher Server - README](./terraform/azure/rancher-server/README.md) - Despliegue de Rancher
- ☸️ [AKS Cluster - README](./terraform/azure/aks-cluster/README.md) - Despliegue de AKS
- �️ [Local Cluster - README](./terraform/local/README.md) - Despliegue con Vagrant
- 📋 [Scripts - README](./scripts/README.md) - Documentación de scripts

### Guías de Aplicación

- 🏪 [MicroStore - README](./app/microProyecto2_CloudComputing/README.md) - Aplicación de microservicios
- ☁️ [Despliegue en AKS](./DEPLOYMENT-AZURE-AKS.md) - Guía paso a paso para Azure
- 💻 [Despliegue Local](./DEPLOYMENT-LOCAL-MINIKUBE.md) - Guía paso a paso para Minikube

## 📚 Referencias Externas

- [Rancher Documentation](https://rancher.com/docs/)
- [Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [MySQL on Kubernetes](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

## 🤝 Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 👥 Equipo

Proyecto desarrollado como parte del curso de Computación en la Nube - 2025

### Integrantes

- **Sebastian Marinez** - Infraestructura base y automatización con Terraform
- **Andres Higuera** - Despliegue de la app en los diferentes clusters disponibles
- **Nicolas Gonzales** - Configuración y pruebas del balanceador de carga
- **Santiago Cortes** - Monitoreo de la app y la infraestructura que la respalda


**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!**
