# 📋 Guía Rápida de Despliegue

## 🚀 Resumen Ejecutivo

Este proyecto despliega una infraestructura multinube Kubernetes con 3 componentes:

1. **Rancher Server** (Azure) - Panel de gestión centralizado
2. **Cluster AKS** (Azure) - Cluster Kubernetes gestionado en la nube
3. **Cluster Local** (VM con Minikube) - Entorno de desarrollo local

> ⚠️ **Nota sobre AWS**: Inicialmente se contempló AWS EKS, pero se excluyó debido a limitaciones de AWS Academy (créditos insuficientes y restricciones de permisos para desplegar aplicaciones).

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

### 3️⃣ Registrar Clusters en Rancher (Manual)

**Proceso idéntico para ambos clusters (AKS y Local)**:

#### Paso 1: Desde Rancher UI
1. Acceder a `https://<RANCHER_IP>`
2. **Clusters** → **Import Existing** → **Generic**
3. Nombrar el cluster (ej: `k8s-azure`, `k8sLocal`)
4. Click **Create**
5. Copiar comando proporcionado

#### Paso 2: Ejecutar comando en el cluster

**Para AKS**:
```bash
az aks get-credentials -g rg-k8s-azure -n k8s-azure
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

**Tiempo estimado**: 5 minutos por cluster (10 minutos total)

---

## 📊 Checklist Completo

### Aprovisionamiento Automático
- [ ] Rancher Server creado con Terraform
- [ ] Cluster AKS creado con Terraform
- [ ] VM Local creada con Vagrant

### Configuración Manual
- [ ] Rancher configurado (password permanente)
- [ ] AKS registrado en Rancher
- [ ] k8sLocal registrado en Rancher

### Verificación Final
- [ ] Los 2 clusters aparecen como **Active** en Rancher UI
- [ ] Todos los nodos muestran estado **Ready**
- [ ] Pods de `cattle-system` están **Running** en cada cluster

---

## ⏱️ Tiempo Total Estimado

| Etapa | Tiempo |
|-------|--------|
| Aprovisionamiento automático | 15-20 min |
| Configuración Rancher | 5 min |
| Registro clusters | 10 min |
| **TOTAL** | **30-35 minutos** |

---

## 🎯 Lo que NO necesitas hacer manualmente

❌ **NO** ejecutar scripts en `scripts/` - Terraform y Vagrant los ejecutan automáticamente

❌ **NO** instalar Docker en Rancher VM - cloud-init lo hace automáticamente

❌ **NO** instalar Minikube en VM local - Vagrant lo hace automáticamente

❌ **NO** configurar networking - Terraform lo configura automáticamente


✅ **SÍ** registrar clusters desde Rancher UI (mismo proceso para ambos)


---

## 📚 Documentación Detallada

- [README Principal](./README.md) - Documentación completa
- [Scripts README](./scripts/README.md) - Detalles de scripts automáticos
- [Despliegue en AKS](./DEPLOYMENT-AZURE-AKS.md) - Guía de aplicación MicroStore en Azure
- [Despliegue Local](./DEPLOYMENT-LOCAL-MINIKUBE.md) - Guía de aplicación MicroStore en Minikube

---

**Última actualización**: Noviembre 12, 2025
