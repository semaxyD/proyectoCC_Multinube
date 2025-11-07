# AKS Cluster - Terraform Configuration

Este módulo de Terraform despliega un cluster Azure Kubernetes Service (AKS).

## Componentes Desplegados

- **Resource Group**: `rg-k8s-azure`
- **AKS Cluster**: Cluster Kubernetes gestionado
- **Virtual Network**: Red privada 10.2.0.0/16 para los nodos
- **Subnet**: 10.2.1.0/24 para el node pool
- **Log Analytics Workspace**: Para monitoreo y métricas
- **Node Pool**: 2 nodos `Standard_B2s` con Ubuntu 22.04 LTS

## Requisitos Previos

1. **Azure CLI** instalado y configurado:
   ```bash
   az login
   az account set --subscription "Azure for Students"
   ```

2. **Terraform** instalado (>= 1.0)

3. **kubectl** instalado (para administrar el cluster)

## Uso

### 1. Inicializar Terraform

```bash
cd terraform/azure/aks-cluster
terraform init
```

### 2. Revisar el Plan

```bash
terraform plan
```

### 3. Aplicar la Configuración

```bash
terraform apply
```

El despliegue puede tomar **8-15 minutos**.

### 4. Obtener Credenciales

```bash
# Usando el comando del output
terraform output -raw get_credentials_command | bash

# O manualmente
az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure

# Verificar nodos
kubectl get nodes -o wide
```

### 5. Verificar el Cluster

```bash
# Ver nodos
kubectl get nodes

# Ver pods del sistema
kubectl get pods -n kube-system

# Ver versión de Kubernetes
kubectl version
```

## Personalización

Crear archivo `terraform.tfvars`:

```hcl
cluster_name       = "k8s-azure"
location           = "East US 2"
node_count         = 3
node_vm_size       = "Standard_D2s_v3"
kubernetes_version = "1.28"
```

## Variables Disponibles

| Variable | Descripción | Default |
|----------|-------------|---------|
| `resource_group_name` | Nombre del resource group | `rg-k8s-azure` |
| `location` | Región de Azure | `East US 2` |
| `cluster_name` | Nombre del cluster | `k8s-azure` |
| `node_count` | Número de nodos | `2` |
| `node_vm_size` | Tamaño de VMs | `Standard_B2s` |
| `kubernetes_version` | Versión de K8s | `1.28` |

## Arquitectura

```
AKS Cluster (k8s-azure)
│
├── Control Plane (Gestionado por Azure)
│   └── API Server: https://<cluster-fqdn>
│
└── Node Pool (default)
    ├── Node 1: Standard_B2s
    │   ├── 2 vCPU
    │   ├── 4 GB RAM
    │   └── 30 GB OS Disk
    │
    └── Node 2: Standard_B2s
        ├── 2 vCPU
        ├── 4 GB RAM
        └── 30 GB OS Disk

Virtual Network: 10.2.0.0/16
└── Subnet: 10.2.1.0/24

Kubernetes Services: 10.1.0.0/16
```

## Registro en Rancher

Una vez desplegado el cluster:

1. Acceder a Rancher UI: `https://<RANCHER_IP>`
2. Ir a **Clusters** → **Import Existing**
3. Seleccionar **Generic**
4. Nombrar el cluster: `k8s-azure`
5. Ejecutar el comando proporcionado:

```bash
# Asegurarse de estar en el contexto correcto
kubectl config use-context k8s-azure

# Ejecutar comando de Rancher
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -

# Verificar agentes de Rancher
kubectl get pods -n cattle-system
```

## Monitoreo

El cluster incluye Azure Monitor integrado:

```bash
# Ver logs en Azure Portal
az monitor log-analytics workspace show \
  --resource-group rg-k8s-azure \
  --workspace-name k8s-azure-logs
```

## Troubleshooting

### Nodos NotReady

```bash
# Verificar estado de nodos
kubectl get nodes
kubectl describe node <node-name>

# Ver logs de kubelet
az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure
kubectl logs -n kube-system <kubelet-pod>
```

### Problemas de Red

```bash
# Verificar subnet
az network vnet subnet show \
  --resource-group rg-k8s-azure \
  --vnet-name k8s-azure-vnet \
  --name k8s-azure-subnet

# Test de conectividad
kubectl run testpod --image=nginx --rm -it -- /bin/bash
```

### Credenciales Expiradas

```bash
# Re-obtener credenciales
az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure --overwrite-existing
```

## Escalado

### Escalar nodos

```bash
# Via Azure CLI
az aks scale --resource-group rg-k8s-azure --name k8s-azure --node-count 3

# Via Terraform
# Editar terraform.tfvars: node_count = 3
terraform apply
```

### Agregar node pool adicional

Editar `main.tf` y agregar:

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  name                  = "additional"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 2
}
```

## Limpieza

```bash
terraform destroy
```

**⚠️ ADVERTENCIA**: Esto eliminará el cluster y TODOS sus recursos.

## Próximos Pasos

1. Registrar cluster en Rancher
2. Desplegar aplicaciones de prueba
3. Configurar Ingress Controllers
4. Configurar almacenamiento persistente

## Notas

- El cluster usa **System Assigned Identity** para gestión de recursos
- Azure Monitor está habilitado por defecto
- Los nodos se despliegan en una subnet dedicada
- El kubeconfig se guarda en `kubeconfig-aks` (agregado a .gitignore)
