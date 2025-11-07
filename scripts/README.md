# Scripts de Automatización# Scripts de Automatización# Scripts de Automatización



Esta carpeta contiene scripts **automáticos** que son ejecutados durante el aprovisionamiento de infraestructura.



## 📜 Scripts Disponibles> ⚠️ **IMPORTANTE**: Estos scripts son **herramientas manuales** para facilitar tareas específicas.> ⚠️ **IMPORTANTE**: Estos scripts son **herramientas manuales** para facilitar tareas específicas.



### 1. `rancher-setup.sh`> > 



Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.



> ✅ **Ejecutado automáticamente** por Terraform mediante `cloud-init.yaml` al crear la VM de Rancher.



**Qué hace:**Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.

- Instala dependencias del sistema

- Instala Docker

- Despliega Rancher en contenedor

- Configura reinicio automático## 🔍 ¿Cuándo usar estos scripts?## 🔍 ¿Cuándo usar estos scripts?

- Verifica que Rancher esté healthy

- Guarda bootstrap password



**No necesitas ejecutar este script manualmente** - Terraform lo hace por ti.| Script | Cuándo usarlo | Automático? || Script | Cuándo usarlo | Automático? |



**Uso manual** (solo si NO usas Terraform):|--------|---------------|-------------||--------|---------------|-------------|

```bash

chmod +x rancher-setup.sh| `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual || `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual |

./rancher-setup.sh

```| `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant || `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant |



---| `register-cluster.sh` | Después de crear cada cluster | ❌ Manual || `register-cluster.sh` | Después de crear cada cluster | ❌ Manual |



### 2. `create-k8sLocal.sh`



Crea un cluster Kubernetes local con Minikube en Ubuntu.### 💡 Notas:### 💡 Notas:



> ✅ **Ejecutado automáticamente** por Vagrant al hacer `vagrant up` en `terraform/local/`.



**Qué hace:**- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)

- Instala Docker

- Instala kubectl- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`

- Instala Minikube

- Crea cluster llamado `k8sLocal`- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI

- Configura kubectl

- Verifica que el cluster esté Ready



**No necesitas ejecutar este script manualmente** - Vagrant lo hace por ti.## 📜 Scripts Disponibles## 📜 Scripts Disponibles



**Uso manual** (solo para debugging):

```bash

chmod +x create-k8sLocal.sh### 1. `rancher-setup.sh`### 1. `rancher-setup.sh`

./create-k8sLocal.sh

```



---Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.



## 🔧 Funcionamiento



### Script 1: `rancher-setup.sh`> ⚠️ **No necesario si usas Terraform** - Terraform ya hace esto automáticamente con `cloud-init.yaml`**Uso:**



**¿Cuándo se ejecuta?**```bash

```bash

cd terraform/azure/rancher-server**Uso:**chmod +x rancher-setup.sh

terraform apply

``````bash./rancher-setup.sh



Durante `terraform apply`, el archivo `cloud-init.yaml` incluye todos los comandos de este script, ejecutándolos automáticamente al crear la VM.chmod +x rancher-setup.sh```



**Resultado:**./rancher-setup.sh

- VM con Rancher corriendo en Docker

- Accesible en `https://<VM_IP>````**Qué hace:**

- Bootstrap password guardado en `/tmp/rancher-bootstrap-password.txt`

- Instala dependencias (curl, vim, etc.)

---

**Qué hace:**- Instala Docker

### Script 2: `create-k8sLocal.sh`

- Instala dependencias (curl, vim, etc.)- Despliega Rancher en contenedor

**¿Cuándo se ejecuta?**

```bash- Instala Docker- Verifica que Rancher esté healthy

cd terraform/local

vagrant up- Despliega Rancher en contenedor- Muestra IP de acceso y bootstrap password

```

- Verifica que Rancher esté healthy

Durante `vagrant up`, el `Vagrantfile` ejecuta este script como provisioner.

- Muestra IP de acceso y bootstrap password**Variables de entorno:**

**Resultado:**

- VM Ubuntu con Minikube instalado```bash

- Cluster `k8sLocal` corriendo

- kubectl configurado**Variables de entorno:**# Cambiar versión de Rancher

- Listo para registrarse en Rancher

```bashRANCHER_VERSION=v2.8.4 ./rancher-setup.sh

---

# Cambiar versión de Rancher```

## 📝 Notas Importantes

RANCHER_VERSION=v2.8.4 ./rancher-setup.sh

### ⚠️ Estos scripts SON automáticos

```---

A diferencia de otras herramientas de configuración, **NO necesitas ejecutar estos scripts manualmente**:



- ✅ `rancher-setup.sh` → Ejecutado por Terraform (cloud-init)

- ✅ `create-k8sLocal.sh` → Ejecutado por Vagrant---### 2. `create-k8sLocal.sh`



### 🔗 Registro de Clusters en Rancher



El registro de clusters se hace **manualmente desde la UI de Rancher**:### 2. `create-k8sLocal.sh`Crea un cluster Kubernetes local con Minikube.



1. Acceder a Rancher UI

2. **Clusters** → **Import Existing** → **Generic**

3. Nombrar el clusterCrea un cluster Kubernetes local con Minikube.**Uso:**

4. Copiar comando proporcionado

5. Ejecutar en CloudShell/terminal del cluster```bash



Ver documentación completa en:> ✅ **Ejecutado automáticamente por Vagrant** al hacer `vagrant up`chmod +x create-k8sLocal.sh

- [`README.md`](../README.md) - Guía general

- [`aws-manual/eks-setup-guide.md`](../aws-manual/eks-setup-guide.md) - Ejemplo con EKS./create-k8sLocal.sh



---**Uso manual:**```



## 🐛 Troubleshooting```bash



### Rancher no arranca después de terraform applychmod +x create-k8sLocal.sh**Qué hace:**



```bash./create-k8sLocal.sh- Instala Docker, kubectl y Minikube

# SSH a la VM

ssh -i terraform/azure/rancher-server/ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>```- Crea cluster llamado `k8sLocal`



# Ver logs de cloud-init- Configura kubectl para usar el contexto

sudo cat /var/log/cloud-init-output.log

**Qué hace:**- Verifica que los nodos estén Ready

# Ver estado de Rancher

sudo docker ps- Instala Docker, kubectl y Minikube- Ejecuta test básico

sudo docker logs rancher

```- Crea cluster llamado `k8sLocal`



### Minikube no arranca después de vagrant up- Configura kubectl para usar el contexto**Requisitos:**



```bash- Verifica que los nodos estén Ready- Ubuntu 22.04 LTS (o similar)

# SSH a la VM

vagrant ssh- Ejecuta test básico- Mínimo 2 CPU, 4GB RAM



# Ver logs del script- 12GB de espacio en disco

cat /var/log/cloud-init-output.log

**Requisitos:**

# Verificar Minikube

minikube status -p k8sLocal- Ubuntu 22.04 LTS (o similar)---

kubectl get nodes

```- Mínimo 2 CPU, 4GB RAM



### Modificar configuración de Minikube- 12GB de espacio en disco### 3. `register-cluster.sh`



Editar `create-k8sLocal.sh` antes de ejecutar `vagrant up`:



```bash---Script para registrar clusters en Rancher.

minikube start -p k8sLocal \

    --driver=docker \

    --cpus=4 \           # Cambiar recursos

    --memory=8192 \      # Cambiar RAM### 3. `register-cluster.sh`**Uso:**

    --disk-size=20g      # Cambiar disco

``````bash



---Script para registrar clusters en Rancher.chmod +x register-cluster.sh



## 📚 Referencias./register-cluster.sh <RANCHER_IP> <RANCHER_TOKEN> [CLUSTER_NAME]



- [Terraform cloud-init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config)**Uso:**```

- [Vagrant Provisioning](https://www.vagrantup.com/docs/provisioning)

- [Rancher Installation](https://rancher.com/docs/rancher/v2.8/en/installation/)```bash

- [Minikube Start](https://minikube.sigs.k8s.io/docs/start/)

chmod +x register-cluster.sh**Ejemplo:**

---

./register-cluster.sh <RANCHER_IP> <RANCHER_TOKEN> [CLUSTER_NAME]```bash

**Última actualización**: Noviembre 2025

```./register-cluster.sh 20.185.23.45 abc123xyz k8s-azure

```

**Ejemplo:**

```bash**Qué hace:**

./register-cluster.sh 20.185.23.45 abc123xyz k8s-azure- Verifica que kubectl esté configurado

```- Muestra nodos del cluster actual

- Aplica configuración de Rancher

**Qué hace:**- Espera a que los agentes se desplieguen

- Verifica que kubectl esté configurado- Verifica registro exitoso

- Muestra nodos del cluster actual

- Aplica configuración de Rancher**Cómo obtener el token:**

- Espera a que los agentes se desplieguen1. Accede a Rancher UI

- Verifica registro exitoso2. Ve a **Clusters** → **Import Existing** → **Generic**

3. Copia el token del comando proporcionado (la parte después de `/v3/import/`)

**Cómo obtener el token:**

1. Accede a Rancher UI---

2. Ve a **Clusters** → **Import Existing** → **Generic**

3. Copia el token del comando proporcionado (la parte después de `/v3/import/`)## 🛠️ Uso General



---### Preparar los scripts



## 🛠️ Uso General```bash

# Dar permisos de ejecución

### Preparar los scriptscd scripts

chmod +x *.sh

```bash```

# Dar permisos de ejecución

cd scripts### Flujo de trabajo recomendado

chmod +x *.sh

```#### 1. Desplegar infraestructura con Terraform



### Flujo de trabajo recomendado```bash

# Rancher Server

#### 1. Desplegar infraestructura con Terraformcd terraform/azure/rancher-server

terraform init && terraform apply

```bash

# Rancher Server# AKS Cluster

cd terraform/azure/rancher-servercd terraform/azure/aks-cluster

terraform init && terraform applyterraform init && terraform apply



# AKS Cluster# VM Local con Minikube

cd terraform/azure/aks-clustercd terraform/local

terraform init && terraform applyvagrant up

```

# VM Local con Minikube

cd terraform/local> ℹ️ **Nota**: El script `rancher-setup.sh` NO es necesario si usas Terraform. Terraform ya instala Rancher automáticamente mediante cloud-init.

vagrant up

```#### 2. Configurar Rancher (MANUAL)



> ℹ️ **Nota**: El script `rancher-setup.sh` NO es necesario si usas Terraform. Terraform ya instala Rancher automáticamente mediante cloud-init.1. Obtener IP de Rancher:

   ```bash

#### 2. Configurar Rancher (MANUAL)   cd terraform/azure/rancher-server

   terraform output rancher_public_ip

1. Obtener IP de Rancher:   ```

   ```bash

   cd terraform/azure/rancher-server2. Acceder a `https://<RANCHER_IP>`

   terraform output rancher_public_ip

   ```3. Obtener bootstrap password:

   ```bash

2. Acceder a `https://<RANCHER_IP>`   ssh -i ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>

   sudo docker logs rancher 2>&1 | grep "Bootstrap Password:"

3. Obtener bootstrap password:   ```

   ```bash

   ssh -i ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>4. Configurar password (ejemplo: `proyectoCCG1`)

   sudo docker logs rancher 2>&1 | grep "Bootstrap Password:"

   ```#### 3. Crear cluster EKS en AWS (MANUAL)



4. Configurar password (ejemplo: `proyectoCCG1`)Seguir la guía: [`aws-manual/eks-setup-guide.md`](../aws-manual/eks-setup-guide.md)



#### 3. Crear cluster EKS en AWS (MANUAL)#### 4. Registrar clusters en Rancher (MANUAL)



Seguir la guía: [`aws-manual/eks-setup-guide.md`](../aws-manual/eks-setup-guide.md)```bash

cd scripts

#### 4. Registrar clusters en Rancher (MANUAL)

# Registrar AKS

```bashaz aks get-credentials -g rg-k8s-azure -n k8s-azure

cd scripts./register-cluster.sh <RANCHER_IP> <TOKEN> k8s-azure



# Registrar AKS# Registrar EKS

az aks get-credentials -g rg-k8s-azure -n k8s-azureaws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1

./register-cluster.sh <RANCHER_IP> <TOKEN> k8s-azure./register-cluster.sh <RANCHER_IP> <TOKEN> rancher-eks-cluster



# Registrar EKS# Registrar k8sLocal

aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1kubectl config use-context k8sLocal

./register-cluster.sh <RANCHER_IP> <TOKEN> rancher-eks-cluster./register-cluster.sh <RANCHER_IP> <TOKEN> k8sLocal

```

# Registrar k8sLocal

kubectl config use-context k8sLocal> 💡 **Tip**: Obtén un token diferente de Rancher UI para cada cluster, o reutiliza el mismo si prefieres.

./register-cluster.sh <RANCHER_IP> <TOKEN> k8sLocal

```---



> 💡 **Tip**: Obtén un token diferente de Rancher UI para cada cluster, o reutiliza el mismo si prefieres.## � Troubleshooting

   ```bash

---   # En una VM Linux con Ubuntu 22.04

   ./rancher-setup.sh

## 🐛 Troubleshooting   ```



### Script falla con "Permission denied"2. **Crear cluster local manualmente**:

   ```bash

```bash   ./create-k8sLocal.sh

# Asegurarse de tener permisos de ejecución   ```

chmod +x script-name.sh

3. **Registrar clusters** (método básico):

# Si persiste, ejecutar con bash explícitamente   ```bash

bash script-name.sh   # Obtener token desde Rancher UI (Clusters → Import → Generic)

```   ./register-cluster.sh <RANCHER_IP> <TOKEN> <CLUSTER_NAME>

   ```

### Docker no está instalado después de ejecutar script

---

```bash

# Verificar que Docker se instaló## 🐛 Troubleshooting

docker --version

### Script falla con "Permission denied"

# Si no está, puede ser necesario reiniciar sesión

# O agregar usuario al grupo docker manualmente```bash

sudo usermod -aG docker $USER# Asegurarse de tener permisos de ejecución

newgrp dockerchmod +x script-name.sh

```

# Si persiste, ejecutar con bash explícitamente

### Minikube no arrancabash script-name.sh

```

```bash

# Verificar recursos disponibles### Docker no está instalado después de ejecutar script

free -h

df -h```bash

# Verificar que Docker se instaló

# Reducir recursos si es necesariodocker --version

minikube start -p k8sLocal --memory=2048 --cpus=1

```# Si no está, puede ser necesario reiniciar sesión

# O agregar usuario al grupo docker manualmente

### Script de registro se queda esperandosudo usermod -aG docker $USER

newgrp docker

```bash```

# Interrumpir con Ctrl+C

# Ver logs manualmente para diagnosticar### Minikube no arranca

kubectl get pods -n cattle-system

kubectl logs -f -n cattle-system <pod-name>```bash

```# Verificar recursos disponibles

free -h

### Error al aplicar manifest de Rancherdf -h



```bash# Reducir recursos si es necesario

# Verificar conectividad a Rancherminikube start -p k8sLocal --memory=2048 --cpus=1

curl -k https://<RANCHER_IP>/ping```



# Verificar que el token sea válido### Script se queda esperando indefinidamente

# Generar nuevo token desde Rancher UI

```bash

# Verificar contexto de kubectl# Interrumpir con Ctrl+C

kubectl config current-context# Ver logs manualmente para diagnosticar

kubectl get nodessudo docker logs rancher

```kubectl get pods -n cattle-system

minikube logs -p k8sLocal

---```



## 📝 Personalización---



### Cambiar versión de Rancher## 📝 Personalización



Editar `rancher-setup.sh`:### Cambiar versión de Rancher

```bash

RANCHER_VERSION="${RANCHER_VERSION:-v2.9.0}"  # Cambiar aquíEditar `rancher-setup.sh`:

``````bash

RANCHER_VERSION="${RANCHER_VERSION:-v2.9.0}"  # Cambiar aquí

O usar variable de entorno:```

```bash

RANCHER_VERSION=v2.9.0 ./rancher-setup.shO usar variable de entorno:

``````bash

RANCHER_VERSION=v2.9.0 ./rancher-setup.sh

### Cambiar recursos de Minikube```



Editar `create-k8sLocal.sh`:### Cambiar recursos de Minikube

```bash

minikube start -p k8sLocal \Editar `create-k8sLocal.sh`:

    --driver=docker \```bash

    --cpus=4 \           # Cambiar aquíminikube start -p k8sLocal \

    --memory=8192 \      # Cambiar aquí    --driver=docker \

    --disk-size=20g \    # Cambiar aquí    --cpus=4 \           # Cambiar aquí

    --kubernetes-version=stable    --memory=8192 \      # Cambiar aquí

```    --disk-size=20g \    # Cambiar aquí

    --kubernetes-version=stable

---```



## 📚 Referencias### Agregar más validaciones



- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)Los scripts incluyen verificaciones básicas. Puedes agregar más:

- [Docker Installation](https://docs.docker.com/engine/install/)

- [Rancher Docs](https://rancher.com/docs/)```bash

- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)# Verificar si un puerto está en uso

if lsof -Pi :443 -sTCP:LISTEN -t >/dev/null ; then

---    echo "Puerto 443 ya en uso"

    exit 1

**Última actualización**: Noviembre 2025fi


# Verificar RAM disponible
AVAILABLE_RAM=$(free -m | awk '/^Mem:/{print $7}')
if [ $AVAILABLE_RAM -lt 2048 ]; then
    echo "RAM insuficiente. Se requieren 2GB libres"
    exit 1
fi
```

---

## 🔄 Scripts Adicionales (Futuro)

### `backup-rancher.sh`

Hacer backup de datos de Rancher:
```bash
#!/bin/bash
BACKUP_DIR="/backup/rancher-$(date +%Y%m%d)"
sudo mkdir -p $BACKUP_DIR
sudo tar -czf $BACKUP_DIR/rancher-data.tar.gz /opt/rancher
echo "Backup guardado en: $BACKUP_DIR"
```

### `update-rancher.sh`

Actualizar Rancher a nueva versión:
```bash
#!/bin/bash
NEW_VERSION="${1:-v2.9.0}"
sudo docker pull rancher/rancher:$NEW_VERSION
sudo docker stop rancher
sudo docker rm rancher
sudo docker run -d --restart=unless-stopped \
  --name rancher \
  -p 80:80 -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  rancher/rancher:$NEW_VERSION
```

### `check-health.sh`

Verificar salud de todos los componentes:
```bash
#!/bin/bash
echo "=== Rancher Health ==="
curl -k -s https://<RANCHER_IP>/healthz

echo "=== AKS Health ==="
kubectl --context=k8s-azure get nodes

echo "=== EKS Health ==="
kubectl --context=<eks-context> get nodes

echo "=== Minikube Health ==="
kubectl --context=k8sLocal get nodes
```

---

## 📚 Referencias

- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)
- [Docker Installation](https://docs.docker.com/engine/install/)
- [Rancher Docs](https://rancher.com/docs/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)

---

**Última actualización**: Noviembre 2025
