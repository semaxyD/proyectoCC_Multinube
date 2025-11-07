# 📋 Guía Rápida de Despliegue

## 🚀 Resumen Ejecutivo

Este proyecto despliega una infraestructura multinube Kubernetes con 4 componentes:

1. **Rancher Server** (Azure) - Panel de gestión centralizado
2. **Cluster AKS** (Azure) - Cluster Kubernetes gestionado
3. **Cluster EKS** (AWS) - Cluster Kubernetes gestionado
4. **Cluster Local** (VM con Minikube) - Entorno de desarrollo

---

## ✅ Pasos Principales

### 1️⃣ Aprovisionar Infraestructura Automática

```bash
# Rancher Server (Azure con Terraform)
cd terraform/azure/rancher-server
terraform init
terraform apply

# Cluster AKS (Azure con Terraform)
cd ../aks-cluster
terraform init
terraform apply

# VM Local con Minikube (Vagrant)
cd ../../local
vagrant up
```

**Tiempo estimado**: 15-20 minutos

---

### 2️⃣ Configurar Rancher (Manual)

1. Obtener IP de Rancher:
   ```bash
   cd terraform/azure/rancher-server
   terraform output rancher_public_ip
   ```

2. Acceder a `https://<RANCHER_IP>`

3. Obtener bootstrap password:
   ```bash
   ssh -i ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>
   sudo docker logs rancher 2>&1 | grep "Bootstrap Password:"
   ```

4. Configurar password permanente (ejemplo: `proyectoCCG1`)

**Tiempo estimado**: 5 minutos

---

### 3️⃣ Crear Cluster EKS (Manual)

Seguir guía completa: [`aws-manual/eks-setup-guide.md`](./aws-manual/eks-setup-guide.md)

**Resumen**:
1. AWS Console → EKS → Create Cluster
2. Usar "Configuración rápida con modo automático"
3. EKS crea automáticamente los node groups
4. Configurar kubectl:
   ```bash
   aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1
   ```

**Tiempo estimado**: 10-15 minutos

---

### 4️⃣ Registrar Clusters en Rancher (Manual)

**Proceso idéntico para todos los clusters (AKS, EKS, Local)**:

#### Paso 1: Desde Rancher UI
1. Acceder a `https://<RANCHER_IP>`
2. **Clusters** → **Import Existing** → **Generic**
3. Nombrar el cluster (ej: `k8s-azure`, `rancher-eks-cluster`, `k8sLocal`)
4. Click **Create**
5. Copiar comando proporcionado

#### Paso 2: Ejecutar comando en el cluster

**Para AKS**:
```bash
az aks get-credentials -g rg-k8s-azure -n k8s-azure
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -
```

**Para EKS**:
```bash
aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -
```

**Para Local**:
```bash
vagrant ssh
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -
```

#### Paso 3: Verificar
```bash
kubectl get namespace cattle-system
kubectl get pods -n cattle-system
```

El cluster debe aparecer como **Active** en Rancher UI en 2-3 minutos.

**Tiempo estimado**: 5 minutos por cluster

---

## 📊 Checklist Completo

### Aprovisionamiento Automático
- [ ] Rancher Server creado con Terraform
- [ ] Cluster AKS creado con Terraform
- [ ] VM Local creada con Vagrant

### Configuración Manual
- [ ] Rancher configurado (password permanente)
- [ ] Cluster EKS creado en AWS Console
- [ ] AKS registrado en Rancher
- [ ] EKS registrado en Rancher
- [ ] k8sLocal registrado en Rancher

### Verificación Final
- [ ] Los 4 clusters aparecen como **Active** en Rancher UI
- [ ] Todos los nodos muestran estado **Ready**
- [ ] Pods de `cattle-system` están **Running** en cada cluster

---

## ⏱️ Tiempo Total Estimado

| Etapa | Tiempo |
|-------|--------|
| Aprovisionamiento automático | 15-20 min |
| Configuración Rancher | 5 min |
| Creación EKS | 10-15 min |
| Registro clusters | 15 min |
| **TOTAL** | **45-55 minutos** |

---

## 🎯 Lo que NO necesitas hacer manualmente

❌ **NO** ejecutar scripts en `scripts/` - Terraform y Vagrant los ejecutan automáticamente
❌ **NO** instalar Docker en Rancher VM - cloud-init lo hace automáticamente
❌ **NO** instalar Minikube en VM local - Vagrant lo hace automáticamente
❌ **NO** configurar networking - Terraform lo configura automáticamente

✅ **SÍ** crear cluster EKS manualmente (limitación AWS Academy)
✅ **SÍ** registrar clusters desde Rancher UI (mismo proceso para todos)

---

## 📚 Documentación Detallada

- [README Principal](./README.md) - Documentación completa
- [Guía EKS](./aws-manual/eks-setup-guide.md) - Creación paso a paso de EKS
- [Scripts README](./scripts/README.md) - Detalles de scripts automáticos
- [Troubleshooting](./docs/troubleshooting.md) - Solución de problemas

---

**Última actualización**: Noviembre 2025
