# Rancher Server - Terraform Configuration

Este módulo de Terraform despliega un servidor Rancher en Azure.

## Componentes Desplegados

- **Resource Group**: `rg-rancher-server`
- **Virtual Network**: Red privada 10.0.0.0/16
- **Subnet**: 10.0.1.0/24
- **Public IP**: IP estática para acceso externo
- **Network Security Group**: Reglas para SSH, HTTP, HTTPS, K8s API
- **VM**: Ubuntu 22.04 LTS con Docker y Rancher v2.8.3

## Requisitos Previos

1. **Azure CLI** instalado y configurado:
   ```bash
   az login
   az account set --subscription "Azure for Students"
   ```

2. **Terraform** instalado (>= 1.0)

3. **Permisos** para crear recursos en Azure

4. **Repositorio clonado**:
   ```bash
   git clone https://github.com/semaxyD/proyectoCC_Multinube.git
   cd proyectoCC_Multinube
   ```

## Uso

### 1. Inicializar Terraform

```bash
cd terraform/azure/rancher-server
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

Confirmar con `yes` cuando se solicite.

### 4. Obtener Outputs

```bash
terraform output
```

Outputs disponibles:
- `rancher_public_ip`: IP pública del servidor
- `rancher_url`: URL de acceso a Rancher
- `ssh_command`: Comando para conectar por SSH
- `get_bootstrap_password_command`: Comando para obtener password inicial

### 5. Acceder a Rancher

1. Esperar 5-10 minutos para que Rancher termine de inicializar
2. Acceder a la URL mostrada en el output
3. Obtener bootstrap password:
   ```bash
   terraform output get_bootstrap_password_command
   # Ejecutar el comando mostrado
   ```
4. Configurar nueva contraseña (recomendado: `proyectoCCG1`)

## Variables Disponibles

Las siguientes variables se pueden modificar editando directamente el archivo `variables.tf` si necesitas personalización:

```hcl
location            = "East US 2"
vm_size             = "Standard_D4s_v3"  # 4 vCPU, 16GB RAM
rancher_version     = "v2.8.3"
```

> 💡 **Nota**: Los valores por defecto están optimizados para Azure for Students. Si necesitas cambiarlos, edita `variables.tf` directamente.

## Variables Disponibles

| Variable | Descripción | Default |
|----------|-------------|---------|
| `resource_group_name` | Nombre del resource group | `rg-rancher-server` |
| `location` | Región de Azure | `East US 2` |
| `vm_size` | Tamaño de la VM | `Standard_D2s_v3` |
| `rancher_version` | Versión de Rancher | `v2.8.3` |

## Arquitectura de Red

```
Internet
    │
    ▼
[Public IP: Static]
    │
    ▼
[NSG: 22, 80, 443, 6443]
    │
    ▼
[NIC: 10.0.1.x]
    │
    ▼
[VM: Ubuntu 22.04 + Docker + Rancher]
```

## Troubleshooting

### Rancher no está accesible

1. Verificar que la VM está corriendo:
   ```bash
   az vm list -g rg-rancher-server -o table
   ```

2. Conectar por SSH y verificar Docker:
   ```bash
   ssh -i ../../../ssh_keys/rancher_key.pem azureuser@<IP>
   sudo docker ps
   sudo docker logs rancher
   ```

3. Verificar NSG:
   ```bash
   az network nsg rule list -g rg-rancher-server --nsg-name rancher-nsg -o table
   ```

### Error de autenticación con Azure

```bash
az login
az account list -o table
az account set --subscription "<subscription-id>"
```

## Limpieza

Para eliminar todos los recursos:

```bash
terraform destroy
```

**⚠️ ADVERTENCIA**: Esto eliminará TODOS los recursos, incluyendo el servidor Rancher y sus datos.

## Próximos Pasos

Después de desplegar Rancher:

1. Configurar password en la UI
2. Desplegar cluster AKS: `cd ../aks-cluster`
3. Registrar clusters en Rancher
4. Desplegar aplicaciones

## Notas

- La VM usa cloud-init para instalación automática
- Docker y Rancher se instalan al primer boot
- Los datos de Rancher se guardan en `/opt/rancher` (persistente)
- La clave SSH se genera automáticamente y se guarda en `ssh_keys/rancher_key.pem`
