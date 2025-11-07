# Scripts de Automatización# Scripts de Automatización



Esta carpeta contiene scripts que **se ejecutan automáticamente** durante el despliegue de infraestructura.Esta carpeta contiene scripts que **se ejecutan automáticamente** durante el despliegue de infraestructura - son utilizados por Terraform y Vagrant.



---### 1. `rancher-setup.sh`> > 



## 🔧 Scripts Disponibles



### 1. `rancher-setup.sh`Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.



**Propósito**: Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.



**Usado por**: Terraform - aprovisionamiento de la VM de Rancher mediante `cloud-init.yaml`> ✅ **Ejecutado automáticamente** por Terraform mediante `cloud-init.yaml` al crear la VM de Rancher.



**Ejecución**: ✅ **Automática** cuando ejecutas `terraform apply` en `terraform/azure/rancher-server/`



**Qué hace:****Qué hace:**Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.

- Instala dependencias del sistema (curl, vim, etc.)

- Instala Docker- Instala dependencias del sistema

- Despliega Rancher en contenedor (puertos 80 y 443)

- Configura reinicio automático- Instala Docker

- Verifica que Rancher esté healthy

- Muestra IP de acceso y bootstrap password- Despliega Rancher en contenedor



**Flujo de ejecución:**- Configura reinicio automático## 🔍 ¿Cuándo usar estos scripts?## 🔍 ¿Cuándo usar estos scripts?

```

terraform apply (rancher-server)- Verifica que Rancher esté healthy

    ↓

cloud-init.yaml ejecuta rancher-setup.sh- Guarda bootstrap password

    ↓

Rancher queda disponible en https://<RANCHER_IP>

```

**No necesitas ejecutar este script manualmente** - Terraform lo hace por ti.| Script | Cuándo usarlo | Automático? || Script | Cuándo usarlo | Automático? |

---



### 2. `create-k8sLocal.sh`

**Uso manual** (solo si NO usas Terraform):|--------|---------------|-------------||--------|---------------|-------------|

**Propósito**: Instala Minikube y crea un cluster Kubernetes local llamado `k8sLocal`.

```bash

**Usado por**: Vagrant - aprovisionamiento de la VM local mediante `Vagrantfile`

chmod +x rancher-setup.sh| `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual || `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual |

**Ejecución**: ✅ **Automática** cuando ejecutas `vagrant up` en `terraform/local/`

./rancher-setup.sh

**Qué hace:**

- Instala Docker, kubectl y Minikube```| `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant || `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant |

- Crea cluster Minikube llamado `k8sLocal`

- Configura kubectl para usar el contexto

- Verifica que los nodos estén Ready

- Ejecuta un test básico (nginx pod)---| `register-cluster.sh` | Después de crear cada cluster | ❌ Manual || `register-cluster.sh` | Después de crear cada cluster | ❌ Manual |



**Flujo de ejecución:**

```

vagrant up (terraform/local/)### 2. `create-k8sLocal.sh`

    ↓

Vagrantfile provisioner ejecuta create-k8sLocal.sh

    ↓

VM con Minikube lista para registrar en RancherCrea un cluster Kubernetes local con Minikube en Ubuntu.### 💡 Notas:### 💡 Notas:

```



---

> ✅ **Ejecutado automáticamente** por Vagrant al hacer `vagrant up` en `terraform/local/`.

### 3. `register-cluster.sh`



**Propósito**: Simplifica el registro de clusters en Rancher mediante token.

**Qué hace:**- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)

**Usado por**: TÚ (manual) - después de crear cada cluster (AKS, EKS, k8sLocal)

- Instala Docker

**Ejecución**: ❌ **Manual** - ejecutas tú después de obtener el token desde Rancher UI

- Instala kubectl- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`

**Uso:**

```bash- Instala Minikube

cd scripts

./register-cluster.sh <RANCHER_IP> <TOKEN> <CLUSTER_NAME>- Crea cluster llamado `k8sLocal`- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI

```

- Configura kubectl

**Ejemplo:**

```bash- Verifica que el cluster esté Ready

./register-cluster.sh 20.185.23.45 abc123xyz k8s-azure

```



**Cómo obtener el token:****No necesitas ejecutar este script manualmente** - Vagrant lo hace por ti.## 📜 Scripts Disponibles## 📜 Scripts Disponibles

1. Accede a Rancher UI

2. Ve a **Clusters** → **Import Existing** → **Generic**

3. Copia el token del comando proporcionado (la parte después de `/v3/import/`)

**Uso manual** (solo para debugging):

---

```bash

## 📋 Resumen: ¿Cuáles se ejecutan automáticamente?

chmod +x create-k8sLocal.sh### 1. `rancher-setup.sh`### 1. `rancher-setup.sh`

| Script | ¿Automático? | Usado por | Cuándo |

|--------|--------------|-----------|--------|./create-k8sLocal.sh

| `rancher-setup.sh` | ✅ Sí | Terraform (cloud-init) | Durante `terraform apply` de rancher-server |

| `create-k8sLocal.sh` | ✅ Sí | Vagrant (provisioner) | Durante `vagrant up` |```

| `register-cluster.sh` | ❌ No | Usuario (manual) | Después de crear cada cluster |



---

---Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.

## 🎯 Flujo Completo de Automatización



### Paso 1: Desplegar Rancher (Automático)

```bash## 🔧 Funcionamiento

cd terraform/azure/rancher-server

terraform apply

# ↓ Terraform usa cloud-init.yaml

# ↓ cloud-init ejecuta rancher-setup.sh automáticamente### Script 1: `rancher-setup.sh`> ⚠️ **No necesario si usas Terraform** - Terraform ya hace esto automáticamente con `cloud-init.yaml`**Uso:**

# ✅ Rancher disponible en https://<IP>

```



### Paso 2: Desplegar AKS (Semi-automático)**¿Cuándo se ejecuta?**```bash

```bash

cd terraform/azure/aks-cluster```bash

terraform apply

# ✅ Cluster AKS listo (sin scripts adicionales)cd terraform/azure/rancher-server**Uso:**chmod +x rancher-setup.sh

```

terraform apply

### Paso 3: Desplegar VM local (Automático)

```bash``````bash./rancher-setup.sh

cd terraform/local

vagrant up

# ↓ Vagrant ejecuta Vagrantfile

# ↓ Provisioner ejecuta create-k8sLocal.sh automáticamenteDurante `terraform apply`, el archivo `cloud-init.yaml` incluye todos los comandos de este script, ejecutándolos automáticamente al crear la VM.chmod +x rancher-setup.sh```

# ✅ Minikube listo en VM local

```



### Paso 4: Crear EKS (Manual desde AWS Console)**Resultado:**./rancher-setup.sh

```bash

# Seguir guía: aws-manual/eks-setup-guide.md- VM con Rancher corriendo en Docker

# ✅ Cluster EKS listo

```- Accesible en `https://<VM_IP>````**Qué hace:**



### Paso 5: Registrar clusters (Manual con ayuda de script)- Bootstrap password guardado en `/tmp/rancher-bootstrap-password.txt`

```bash

cd scripts- Instala dependencias (curl, vim, etc.)



# Registrar AKS---

az aks get-credentials -g rg-k8s-azure -n k8s-azure

./register-cluster.sh <RANCHER_IP> <TOKEN> k8s-azure**Qué hace:**- Instala Docker



# Registrar EKS### Script 2: `create-k8sLocal.sh`

aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1

./register-cluster.sh <RANCHER_IP> <TOKEN> rancher-eks-cluster- Instala dependencias (curl, vim, etc.)- Despliega Rancher en contenedor



# Registrar k8sLocal**¿Cuándo se ejecuta?**

kubectl config use-context k8sLocal

./register-cluster.sh <RANCHER_IP> <TOKEN> k8sLocal```bash- Instala Docker- Verifica que Rancher esté healthy



# ✅ Todos los clusters visibles desde Rancher UIcd terraform/local

```

vagrant up- Despliega Rancher en contenedor- Muestra IP de acceso y bootstrap password

---

```

## ⚠️ Aclaración Importante

- Verifica que Rancher esté healthy

**Estos scripts NO se ejecutan manualmente por ti** (excepto `register-cluster.sh`). Son utilizados por las herramientas de automatización:

Durante `vagrant up`, el `Vagrantfile` ejecuta este script como provisioner.

- ✅ `rancher-setup.sh` → **Terraform lo ejecuta** automáticamente vía cloud-init

- ✅ `create-k8sLocal.sh` → **Vagrant lo ejecuta** automáticamente vía provisioner- Muestra IP de acceso y bootstrap password**Variables de entorno:**

- ❌ `register-cluster.sh` → **Tú lo ejecutas** manualmente (es el único)

**Resultado:**

Si ves estos scripts en la carpeta, no significa que debas ejecutarlos. Son parte de la infraestructura como código y se ejecutan solos durante el aprovisionamiento.

- VM Ubuntu con Minikube instalado```bash

---

- Cluster `k8sLocal` corriendo

## 🐛 Troubleshooting

- kubectl configurado**Variables de entorno:**# Cambiar versión de Rancher

### Rancher no arranca después de `terraform apply`

- Listo para registrarse en Rancher

```bash

# SSH a la VM```bashRANCHER_VERSION=v2.8.4 ./rancher-setup.sh

ssh -i terraform/azure/rancher-server/ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>

---

# Ver logs de cloud-init (incluye ejecución de rancher-setup.sh)

sudo cat /var/log/cloud-init-output.log# Cambiar versión de Rancher```



# Ver estado de Rancher## 📝 Notas Importantes

sudo docker ps

sudo docker logs rancherRANCHER_VERSION=v2.8.4 ./rancher-setup.sh

```

### ⚠️ Estos scripts SON automáticos

### Minikube no arranca después de `vagrant up`

```---

```bash

# SSH a la VMA diferencia de otras herramientas de configuración, **NO necesitas ejecutar estos scripts manualmente**:

vagrant ssh



# Ver logs del script (ejecutado por Vagrant)

cat /var/log/cloud-init-output.log- ✅ `rancher-setup.sh` → Ejecutado por Terraform (cloud-init)



# Verificar Minikube- ✅ `create-k8sLocal.sh` → Ejecutado por Vagrant---### 2. `create-k8sLocal.sh`

minikube status -p k8sLocal

kubectl get nodes

```

### 🔗 Registro de Clusters en Rancher

### Script de registro se queda esperando



```bash

# Interrumpir con Ctrl+CEl registro de clusters se hace **manualmente desde la UI de Rancher**:### 2. `create-k8sLocal.sh`Crea un cluster Kubernetes local con Minikube.

# Ver logs manualmente para diagnosticar

kubectl get pods -n cattle-system

kubectl logs -f -n cattle-system <pod-name>

```1. Acceder a Rancher UI



---2. **Clusters** → **Import Existing** → **Generic**



## 📚 Referencias3. Nombrar el clusterCrea un cluster Kubernetes local con Minikube.**Uso:**



- [Terraform cloud-init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config)4. Copiar comando proporcionado

- [Vagrant Provisioning](https://www.vagrantup.com/docs/provisioning)

- [Rancher Installation](https://rancher.com/docs/rancher/v2.8/en/installation/)5. Ejecutar en CloudShell/terminal del cluster```bash

- [Minikube Start](https://minikube.sigs.k8s.io/docs/start/)



---

Ver documentación completa en:> ✅ **Ejecutado automáticamente por Vagrant** al hacer `vagrant up`chmod +x create-k8sLocal.sh

**Última actualización**: Noviembre 2025

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
