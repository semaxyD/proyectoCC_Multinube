# Proyecto Multinube - Infraestructura Kubernetes

Proyecto de infraestructura multinube con Kubernetes, gestionado centralmente con Rancher.

## 🚀 Inicio Rápido

### Resumen de Pasos Principales

```bash
# 1. Aprovisionar infraestructura Azure con Terraform
cd terraform/azure/rancher-server && terraform init && terraform apply
cd ../aks-cluster && terraform init && terraform apply

# 2. Crear VM local con Vagrant
cd ../../local && vagrant up

# 3. Crear cluster EKS manualmente en AWS Console
# Ver guía: aws-manual/eks-setup-guide.md

# 4. Configurar Rancher y registrar clusters desde UI
# Rancher UI → Import Existing → Copiar comando → Ejecutar en cada cluster
```

> 📖 **Ver guía completa paso a paso**: [`QUICK_START.md`](./QUICK_START.md) (~45-55 minutos total)
> 
> 💡 **Nota**: Los pasos 3 y 4 son manuales. Ver secciones detalladas abajo para cada uno.

---

## 🏗️ Arquitectura

### Componentes Principales

1. **Rancher Server** (Azure)
   - Panel de gestión centralizado
   - Versión: v2.8.3
   - Gestiona clusters de múltiples nubes

2. **Cluster AKS** (Azure Kubernetes Service)
   - 2 nodos `Standard_B2s`
   - Ubuntu 22.04 LTS
   - Integrado con Azure Monitor

3. **Cluster EKS** (AWS Elastic Kubernetes Service)
   - 2 nodos `t3.medium`
   - Amazon Linux 2 / Ubuntu 22.04 LTS
   - Creación manual (limitaciones AWS Academy)

4. **Cluster Local** (Minikube)
   - Entorno de desarrollo local
   - 2 vCPU, 4GB RAM mínimo

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
│   ├── rancher-setup.sh         # Instalación Rancher (MANUAL)
│   ├── create-k8sLocal.sh       # Creación cluster local (usado por Vagrant)
│   └── register-cluster.sh      # Registro de clusters (MANUAL)
├── aws-manual/                   # Documentación AWS EKS (MANUAL)
│   └── eks-setup-guide.md       # Guía paso a paso
└── docs/                         # Documentación adicional
    └── troubleshooting.md
```

### � ¿Qué es automático y qué es manual?

| Componente | Método | Automatización |
|-----------|--------|----------------|
| **Rancher Server** | Terraform + cloud-init | ✅ Totalmente automático |
| **AKS Cluster** | Terraform | ✅ Totalmente automático |
| **EKS Cluster** | AWS Console | ❌ Manual (limitación AWS Academy) |
| **VM Local (Vagrant)** | Vagrant + script | ✅ Automático con `vagrant up` |
| **Registro en Rancher** | Script helper | ⚠️ Semi-manual (copiar token) |

> 💡 **Nota sobre scripts**: Los scripts en `scripts/` son **herramientas manuales** para facilitar tareas. El único que se ejecuta automáticamente es `create-k8sLocal.sh` cuando usas Vagrant.

## �🚀 Requisitos Previos

### Herramientas Necesarias

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [AWS CLI](https://aws.amazon.com/cli/) (para EKS manual)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://www.vagrantup.com/) (para cluster local)

### Credenciales

- **Azure**: Suscripción activa (Azure for Students)
- **AWS**: Cuenta AWS Academy
- **Local**: VirtualBox instalado

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

### Paso 4: Cluster EKS (Manual)

> ⚠️ **Importante**: Debido a limitaciones de AWS Academy (no permite uso de Terraform con LabRole), el cluster EKS debe crearse **manualmente** desde la consola de AWS.

Ver guía detallada en: [`aws-manual/eks-setup-guide.md`](./aws-manual/eks-setup-guide.md)

**Resumen:**
1. Usar "Configuración rápida con modo automático" en AWS Console
2. EKS crea automáticamente los node groups (no requiere configuración manual)
3. Configurar kubectl: `aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1`
4. Registrar en Rancher usando el **mismo proceso del Paso 3** (UI + comando)

---

### Paso 5: Cluster Local con Vagrant + Minikube

#### 5.1 Crear VM y cluster

> ℹ️ **Automatizado con Vagrant**: El script `create-k8sLocal.sh` se ejecuta automáticamente.

```bash
# Crear VM y cluster automáticamente
cd terraform/local
vagrant up

# Verificar cluster
vagrant ssh -c "kubectl get nodes"
```

#### 5.2 Registrar en Rancher

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
- [ ] **Crear EKS**: Seguir guía en `aws-manual/eks-setup-guide.md` (modo automático de AWS)
- [ ] **Registrar AKS en Rancher**: UI → Import → Ejecutar comando en AKS
- [ ] **Registrar EKS en Rancher**: UI → Import → Ejecutar comando en CloudShell
- [ ] **Registrar k8sLocal en Rancher**: UI → Import → Ejecutar comando en VM

### ✔️ Verificación

- [ ] Todos los clusters aparecen como **Active** en Rancher UI
- [ ] Todos los nodos muestran estado **Ready**
- [ ] Pods de `cattle-system` están **Running** en cada cluster

---

## 🐛 Troubleshooting

Ver guía completa en: [`docs/troubleshooting.md`](./docs/troubleshooting.md)

### Problemas Comunes

1. **Rancher no accesible**: Verificar Security Groups y que el contenedor esté `healthy`
2. **Cluster no se registra**: Verificar conectividad de red y certificados SSL
3. **Nodos NotReady**: Verificar recursos (CPU/RAM) y logs de kubelet

## 📚 Documentación Adicional

### Guías Paso a Paso

- 📖 [Guía de Inicio Rápido](./docs/quick-start.md) - Despliega todo en 30 minutos
- ✅ [Checklist de Deployment](./docs/deployment-checklist.md) - Checklist completo paso a paso
- 🔧 [Guía de Troubleshooting](./docs/troubleshooting.md) - Solución de problemas comunes
- 📋 [Comandos Útiles](./docs/commands-cheatsheet.md) - Cheat sheet de comandos

### Documentación Técnica

- 🏗️ [Estructura del Proyecto](./docs/project-structure.md) - Organización de archivos
- 🚀 [Mejoras Futuras](./docs/future-improvements.md) - Optimizaciones propuestas
- 🔐 [Guía de EKS](./aws-manual/eks-setup-guide.md) - Creación manual de cluster AWS

### Documentación de Módulos

- [Rancher Server - README](./terraform/azure/rancher-server/README.md)
- [AKS Cluster - README](./terraform/azure/aks-cluster/README.md)
- [Scripts - README](./scripts/README.md)

## 📚 Referencias Externas

- [Rancher Documentation](https://rancher.com/docs/)
- [Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

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

- **Tu Nombre** - Infraestructura base y automatización con Terraform
- *(Agregar otros integrantes)*

## 📝 Licencia

Este proyecto es con fines educativos.

## 🙏 Agradecimientos

- Profesor y equipo docente del curso
- Comunidad de Rancher
- Documentación de Azure, AWS y Kubernetes

---

**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!**
