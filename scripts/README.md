# Scripts de Automatización# Scripts de Automatización# Scripts de Automatización



Esta carpeta contiene scripts que **se ejecutan automáticamente** durante el despliegue de infraestructura con Terraform y Vagrant.



---Esta carpeta contiene scripts que **se ejecutan automáticamente** durante el despliegue de infraestructura.Esta carpeta contiene scripts que **se ejecutan automáticamente** durante el despliegue de infraestructura - son utilizados por Terraform y Vagrant.



## 🔧 Scripts Disponibles



### 1. `rancher-setup.sh`---### 1. `rancher-setup.sh`> > 



**Propósito**: Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.



**Usado por**: Terraform - aprovisionamiento de la VM de Rancher mediante `cloud-init.yaml`## 🔧 Scripts Disponibles



**Ejecución**: ✅ **Automática** cuando ejecutas `terraform apply` en `terraform/azure/rancher-server/`



**Qué hace:**### 1. `rancher-setup.sh`Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.> **Excepción**: El script `create-k8sLocal.sh` SÍ es ejecutado automáticamente por Vagrant al hacer `vagrant up` en `terraform/local/`.

- Instala dependencias del sistema (curl, vim, etc.)

- Instala Docker

- Despliega Rancher en contenedor (puertos 80 y 443)

- Configura reinicio automático**Propósito**: Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.

- Verifica que Rancher esté healthy

- Muestra IP de acceso y bootstrap password



**Flujo de ejecución:****Usado por**: Terraform - aprovisionamiento de la VM de Rancher mediante `cloud-init.yaml`> ✅ **Ejecutado automáticamente** por Terraform mediante `cloud-init.yaml` al crear la VM de Rancher.



```

terraform apply (rancher-server)

    ↓**Ejecución**: ✅ **Automática** cuando ejecutas `terraform apply` en `terraform/azure/rancher-server/`

cloud-init.yaml ejecuta rancher-setup.sh

    ↓

Rancher queda disponible en https://<RANCHER_IP>

```**Qué hace:****Qué hace:**Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.Esta carpeta contiene scripts para facilitar el despliegue y gestión de la infraestructura multinube.



**No necesitas ejecutar este script manualmente** - Terraform lo hace por ti.- Instala dependencias del sistema (curl, vim, etc.)



---- Instala Docker- Instala dependencias del sistema



### 2. `create-k8sLocal.sh`- Despliega Rancher en contenedor (puertos 80 y 443)



**Propósito**: Instala Minikube y crea un cluster Kubernetes local llamado `k8sLocal`.- Configura reinicio automático- Instala Docker



**Usado por**: Vagrant - aprovisionamiento de la VM local mediante `Vagrantfile`- Verifica que Rancher esté healthy



**Ejecución**: ✅ **Automática** cuando ejecutas `vagrant up` en `terraform/local/`- Muestra IP de acceso y bootstrap password- Despliega Rancher en contenedor



**Qué hace:**

- Instala Docker, kubectl y Minikube

- Crea cluster Minikube llamado `k8sLocal`**Flujo de ejecución:**- Configura reinicio automático## 🔍 ¿Cuándo usar estos scripts?## 🔍 ¿Cuándo usar estos scripts?

- Configura kubectl para usar el contexto

- Verifica que el cluster esté listo```

- Muestra información del cluster

terraform apply (rancher-server)- Verifica que Rancher esté healthy

**Flujo de ejecución:**

    ↓

```

vagrant up (terraform/local)cloud-init.yaml ejecuta rancher-setup.sh- Guarda bootstrap password

    ↓

Vagrantfile ejecuta create-k8sLocal.sh    ↓

    ↓

Cluster k8sLocal listo en la VMRancher queda disponible en https://<RANCHER_IP>

```

```

**No necesitas ejecutar este script manualmente** - Vagrant lo hace por ti.

**No necesitas ejecutar este script manualmente** - Terraform lo hace por ti.| Script | Cuándo usarlo | Automático? || Script | Cuándo usarlo | Automático? |

---

---

## 🔍 ¿Cuándo usar estos scripts?



| Script | Cuándo usarlo | Automático? |

|--------|---------------|-------------|### 2. `create-k8sLocal.sh`

| `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual |

| `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático |**Uso manual** (solo si NO usas Terraform):|--------|---------------|-------------||--------|---------------|-------------|



### Uso Manual de `rancher-setup.sh` (sin Terraform)**Propósito**: Instala Minikube y crea un cluster Kubernetes local llamado `k8sLocal`.



```bash```bash

# Si deseas instalar Rancher en una VM existente manualmente

chmod +x rancher-setup.sh**Usado por**: Vagrant - aprovisionamiento de la VM local mediante `Vagrantfile`

./rancher-setup.sh

```chmod +x rancher-setup.sh| `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual || `rancher-setup.sh` | Solo si NO usas Terraform (instalación manual) | ❌ Manual |



### Uso Manual de `create-k8sLocal.sh` (sin Vagrant)**Ejecución**: ✅ **Automática** cuando ejecutas `vagrant up` en `terraform/local/`



```bash./rancher-setup.sh

# Si deseas crear el cluster en una VM existente manualmente

chmod +x create-k8sLocal.sh**Qué hace:**

./create-k8sLocal.sh

```- Instala Docker, kubectl y Minikube```| `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant || `create-k8sLocal.sh` | Ejecutado por Vagrant automáticamente | ✅ Automático con Vagrant |



---- Crea cluster Minikube llamado `k8sLocal`



## 📊 Tabla de Automatización- Configura kubectl para usar el contexto



| Componente | Script | Ejecutado por | Cuándo |- Verifica que los nodos estén Ready

|-----------|--------|---------------|--------|

| **Rancher Server** | `rancher-setup.sh` | Terraform (cloud-init) | `terraform apply` en `azure/rancher-server/` |- Ejecuta un test básico (nginx pod)---| `register-cluster.sh` | Después de crear cada cluster | ❌ Manual || `register-cluster.sh` | Después de crear cada cluster | ❌ Manual |

| **Cluster AKS** | *(ninguno)* | Terraform | `terraform apply` en `azure/aks-cluster/` |

| **Cluster Local** | `create-k8sLocal.sh` | Vagrant (provisioner) | `vagrant up` en `terraform/local/` |

| **Registro en Rancher** | *(manual desde UI)* | Usuario | Después de crear cada cluster |

**Flujo de ejecución:**

---

```

## 📝 Flujo Completo de Despliegue

vagrant up (terraform/local/)### 2. `create-k8sLocal.sh`

### Paso 1: Rancher Server (Automático con Terraform)

    ↓

```bash

cd terraform/azure/rancher-serverVagrantfile provisioner ejecuta create-k8sLocal.sh

terraform init

terraform apply    ↓

```

VM con Minikube lista para registrar en RancherCrea un cluster Kubernetes local con Minikube en Ubuntu.### 💡 Notas:### 💡 Notas:

**Resultado:**

- VM con Rancher corriendo en Docker```

- Accesible en `https://<VM_IP>`

- Bootstrap password guardado en `/tmp/rancher-bootstrap-password.txt`



------



### Paso 2: Cluster AKS (Automático con Terraform)> ✅ **Ejecutado automáticamente** por Vagrant al hacer `vagrant up` en `terraform/local/`.



```bash### 3. `register-cluster.sh`

cd terraform/azure/aks-cluster

terraform init

terraform apply

```**Propósito**: Simplifica el registro de clusters en Rancher mediante token.



**Resultado:****Qué hace:**- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)- **`rancher-setup.sh`**: NO es necesario si usas Terraform (ya incluido en `cloud-init.yaml`)

- Cluster AKS con 2 nodos

- Kubernetes 1.33.5**Usado por**: TÚ (manual) - después de crear cada cluster (AKS, k8sLocal)

- Azure Monitor habilitado

- Instala Docker

---

**Ejecución**: ❌ **Manual** - ejecutas tú después de obtener el token desde Rancher UI

### Paso 3: Cluster Local (Automático con Vagrant)

- Instala kubectl- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`- **`create-k8sLocal.sh`**: Se ejecuta automáticamente al hacer `vagrant up`

```bash

cd terraform/local**Uso:**

vagrant up

``````bash- Instala Minikube



**Resultado:**cd scripts

- VM Ubuntu 22.04 con VirtualBox

- Minikube instalado y corriendo./register-cluster.sh <RANCHER_IP> <TOKEN> <CLUSTER_NAME>- Crea cluster llamado `k8sLocal`- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI- **`register-cluster.sh`**: Simple y claro - solo requiere copiar token desde Rancher UI

- Cluster `k8sLocal` listo

```

---

- Configura kubectl

### Paso 4: Configurar Rancher (Manual)

**Ejemplo:**

1. Obtener IP de Rancher:

   ```bash```bash- Verifica que el cluster esté Ready

   cd terraform/azure/rancher-server

   terraform output rancher_public_ip./register-cluster.sh 20.185.23.45 abc123xyz k8s-azure

   ```

```

2. Acceder a `https://<RANCHER_IP>`



3. Obtener bootstrap password:

   ```bash**Cómo obtener el token:****No necesitas ejecutar este script manualmente** - Vagrant lo hace por ti.## 📜 Scripts Disponibles## 📜 Scripts Disponibles

   ssh -i ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>

   sudo docker logs rancher 2>&1 | grep "Bootstrap Password:"1. Accede a Rancher UI

   ```

2. Ve a **Clusters** → **Import Existing** → **Generic**

4. Configurar password (ejemplo: `proyectoCCG1`)

3. Copia el token del comando proporcionado (la parte después de `/v3/import/`)

---

**Uso manual** (solo para debugging):

### Paso 5: Registrar clusters en Rancher (Manual desde UI)

---

**Para cada cluster (AKS y k8sLocal):**

```bash

1. En Rancher UI:

   - **Clusters** → **Import Existing** → **Generic**## 📋 Resumen: ¿Cuáles se ejecutan automáticamente?

   - Nombrar el cluster

   - Copiar comando proporcionadochmod +x create-k8sLocal.sh### 1. `rancher-setup.sh`### 1. `rancher-setup.sh`



2. Ejecutar comando en cada cluster:| Script | ¿Automático? | Usado por | Cuándo |



**Para AKS**:|--------|--------------|-----------|--------|./create-k8sLocal.sh

```bash

az aks get-credentials -g rg-k8s-azure -n k8s-azure| `rancher-setup.sh` | ✅ Sí | Terraform (cloud-init) | Durante `terraform apply` de rancher-server |

kubectl config current-context  # Verificar contexto

| `create-k8sLocal.sh` | ✅ Sí | Vagrant (provisioner) | Durante `vagrant up` |```

# Ejecutar comando copiado de Rancher

curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -| `register-cluster.sh` | ❌ No | Usuario (manual) | Después de crear cada cluster |

```



**Para k8sLocal**:

```bash---

vagrant ssh

kubectl config use-context k8sLocal---Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.Instala Docker y despliega Rancher v2.8.3 en Ubuntu 22.04 LTS.

kubectl config current-context  # Verificar contexto

## 🎯 Flujo Completo de Automatización

# Ejecutar comando copiado de Rancher

curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -

```

### Paso 1: Desplegar Rancher (Automático)

3. Verificar en cada cluster:

```bash```bash## 🔧 Funcionamiento

kubectl get namespace cattle-system

kubectl get pods -n cattle-systemcd terraform/azure/rancher-server

```

terraform apply

> 💡 **Tip**: Obtén un token diferente de Rancher UI para cada cluster, o reutiliza el mismo si prefieres.

# ↓ Terraform usa cloud-init.yaml

---

# ↓ cloud-init ejecuta rancher-setup.sh automáticamente### Script 1: `rancher-setup.sh`> ⚠️ **No necesario si usas Terraform** - Terraform ya hace esto automáticamente con `cloud-init.yaml`**Uso:**

## 🐛 Troubleshooting

# ✅ Rancher disponible en https://<IP>

### Rancher no arranca después de terraform apply

```

```bash

# SSH a la VM

ssh -i terraform/azure/rancher-server/ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>

### Paso 2: Desplegar AKS (Semi-automático)**¿Cuándo se ejecuta?**```bash

# Ver logs de cloud-init

sudo cat /var/log/cloud-init-output.log```bash



# Ver logs de Ranchercd terraform/azure/aks-cluster```bash

sudo docker logs rancher -f

terraform apply

# Reiniciar Rancher si es necesario

sudo docker restart rancher# ✅ Cluster AKS listo (sin scripts adicionales)cd terraform/azure/rancher-server**Uso:**chmod +x rancher-setup.sh

```

```

### Minikube no inicia en Vagrant

terraform apply

```bash

vagrant ssh### Paso 3: Desplegar VM local (Automático)



# Ver logs del script```bash``````bash./rancher-setup.sh

sudo cat /var/log/cloud-init-output.log

cd terraform/local

# Reiniciar Minikube

minikube deletevagrant up

minikube start --driver=docker --memory=2048 --cpus=2

# ↓ Vagrant ejecuta Vagrantfile

# Ver estado

minikube status# ↓ Provisioner ejecuta create-k8sLocal.sh automáticamenteDurante `terraform apply`, el archivo `cloud-init.yaml` incluye todos los comandos de este script, ejecutándolos automáticamente al crear la VM.chmod +x rancher-setup.sh```

kubectl get nodes

```# ✅ Minikube listo en VM local

```

### Cluster no se registra en Rancher

### Paso 4: Registrar clusters (Manual con ayuda de script)

```bash

# Verificar que cattle-system se creó```bash

kubectl get namespace cattle-systemcd scripts



# Ver pods de cattle-system# Registrar AKS

kubectl get pods -n cattle-systemaz aks get-credentials -g rg-k8s-azure -n k8s-azure

./register-cluster.sh <RANCHER_IP> <TOKEN> k8s-azure

# Ver logs de los pods de cattle

kubectl logs -n cattle-system <pod-name># Registrar k8sLocal

kubectl config use-context k8sLocal

# Verificar conectividad a Rancher./register-cluster.sh <RANCHER_IP> <TOKEN> k8sLocal

curl -k https://<RANCHER_IP>/ping

``````



### Kubectl muestra "connection refused"



```bash### Paso 4: Crear EKS (Manual desde AWS Console)**Resultado:**./rancher-setup.sh

# Para AKS

az aks get-credentials -g rg-k8s-azure -n k8s-azure --overwrite-existing```bash

kubectl get nodes

# Seguir guía: aws-manual/eks-setup-guide.md- VM con Rancher corriendo en Docker

# Para k8sLocal

kubectl config use-context k8sLocal# ✅ Cluster EKS listo

minikube status

``````- Accesible en `https://<VM_IP>````**Qué hace:**



---



## 📚 Detalles Técnicos de los Scripts### Paso 5: Registrar clusters (Manual con ayuda de script)- Bootstrap password guardado en `/tmp/rancher-bootstrap-password.txt`



### `rancher-setup.sh````bash



**Versiones instaladas:**cd scripts- Instala dependencias (curl, vim, etc.)

- Docker: latest (vía get.docker.com)

- Rancher: v2.8.3 (imagen `rancher/rancher:v2.8.3`)



**Puertos expuestos:**# Registrar AKS---

- 80 (HTTP)

- 443 (HTTPS)az aks get-credentials -g rg-k8s-azure -n k8s-azure



**Volumen persistente:**./register-cluster.sh <RANCHER_IP> <TOKEN> k8s-azure**Qué hace:**- Instala Docker

- `/opt/rancher:/var/lib/rancher`



**Logs:**

- Script: `/var/log/cloud-init-output.log`# Registrar EKS### Script 2: `create-k8sLocal.sh`

- Rancher: `docker logs rancher`

aws eks update-kubeconfig --name rancher-eks-cluster --region us-east-1

---

./register-cluster.sh <RANCHER_IP> <TOKEN> rancher-eks-cluster- Instala dependencias (curl, vim, etc.)- Despliega Rancher en contenedor

### `create-k8sLocal.sh`



**Versiones instaladas:**

- Docker: latest# Registrar k8sLocal**¿Cuándo se ejecuta?**

- kubectl: latest stable

- Minikube: latest stablekubectl config use-context k8sLocal



**Configuración de Minikube:**./register-cluster.sh <RANCHER_IP> <TOKEN> k8sLocal```bash- Instala Docker- Verifica que Rancher esté healthy

- Driver: docker

- Memoria: 2048 MB

- CPUs: 2

- Disk: 12GB# ✅ Todos los clusters visibles desde Rancher UIcd terraform/local

- Nombre del cluster: `k8sLocal`

```

**Ubicaciones:**

- Config kubectl: `~/.kube/config`vagrant up- Despliega Rancher en contenedor- Muestra IP de acceso y bootstrap password

- Minikube home: `~/.minikube/`

---

**Logs:**

- Script: `/var/log/cloud-init-output.log````

- Minikube: `minikube logs`

## ⚠️ Aclaración Importante

---

- Verifica que Rancher esté healthy

## 📖 Comandos Útiles

**Estos scripts NO se ejecutan manualmente por ti** (excepto `register-cluster.sh`). Son utilizados por las herramientas de automatización:

### Rancher

Durante `vagrant up`, el `Vagrantfile` ejecuta este script como provisioner.

```bash

# Ver estado del contenedor- ✅ `rancher-setup.sh` → **Terraform lo ejecuta** automáticamente vía cloud-init

sudo docker ps -a | grep rancher

- ✅ `create-k8sLocal.sh` → **Vagrant lo ejecuta** automáticamente vía provisioner- Muestra IP de acceso y bootstrap password**Variables de entorno:**

# Ver logs en tiempo real

sudo docker logs rancher -f --tail 50- ❌ `register-cluster.sh` → **Tú lo ejecutas** manualmente (es el único)



# Reiniciar Rancher**Resultado:**

sudo docker restart rancher

Si ves estos scripts en la carpeta, no significa que debas ejecutarlos. Son parte de la infraestructura como código y se ejecutan solos durante el aprovisionamiento.

# Detener Rancher

sudo docker stop rancher- VM Ubuntu con Minikube instalado```bash



# Iniciar Rancher---

sudo docker start rancher

```- Cluster `k8sLocal` corriendo



### Minikube## 🐛 Troubleshooting



```bash- kubectl configurado**Variables de entorno:**# Cambiar versión de Rancher

# Ver estado

minikube status### Rancher no arranca después de `terraform apply`



# Ver logs- Listo para registrarse en Rancher

minikube logs

```bash

# Acceder al nodo

minikube ssh# SSH a la VM```bashRANCHER_VERSION=v2.8.4 ./rancher-setup.sh



# Ver IPssh -i terraform/azure/rancher-server/ssh_keys/rancher_key.pem azureuser@<RANCHER_IP>

minikube ip

---

# Detener

minikube stop# Ver logs de cloud-init (incluye ejecución de rancher-setup.sh)



# Iniciarsudo cat /var/log/cloud-init-output.log# Cambiar versión de Rancher```

minikube start



# Eliminar y recrear

minikube delete# Ver estado de Rancher## 📝 Notas Importantes

minikube start --driver=docker --memory=2048 --cpus=2

```sudo docker ps



### Kubectlsudo docker logs rancherRANCHER_VERSION=v2.8.4 ./rancher-setup.sh



```bash```

# Ver contextos disponibles

kubectl config get-contexts### ⚠️ Estos scripts SON automáticos



# Cambiar de contexto### Minikube no arranca después de `vagrant up`

kubectl config use-context <context-name>

```---

# Ver contexto actual

kubectl config current-context```bash



# Ver nodos# SSH a la VMA diferencia de otras herramientas de configuración, **NO necesitas ejecutar estos scripts manualmente**:

kubectl get nodes -o wide

vagrant ssh

# Ver todos los recursos

kubectl get all --all-namespaces



# Ver pods de cattle-system# Ver logs del script (ejecutado por Vagrant)

kubectl get pods -n cattle-system

```cat /var/log/cloud-init-output.log- ✅ `rancher-setup.sh` → Ejecutado por Terraform (cloud-init)



---



## 📚 Referencias# Verificar Minikube- ✅ `create-k8sLocal.sh` → Ejecutado por Vagrant---### 2. `create-k8sLocal.sh`



- [Terraform cloud-init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config)minikube status -p k8sLocal

- [Vagrant Provisioning](https://www.vagrantup.com/docs/provisioning)

- [Rancher Installation](https://rancher.com/docs/rancher/v2.8/en/installation/)kubectl get nodes

- [Minikube Start](https://minikube.sigs.k8s.io/docs/start/)

```

---

### 🔗 Registro de Clusters en Rancher

Ver documentación completa en:

### Script de registro se queda esperando

- [`README.md`](../README.md) - Guía general del proyecto

- [`terraform/azure/rancher-server/README.md`](../terraform/azure/rancher-server/README.md) - Despliegue de Rancher

- [`terraform/azure/aks-cluster/README.md`](../terraform/azure/aks-cluster/README.md) - Despliegue de AKS

- [`terraform/local/README.md`](../terraform/local/README.md) - Despliegue local con Vagrant```bash



---# Interrumpir con Ctrl+CEl registro de clusters se hace **manualmente desde la UI de Rancher**:### 2. `create-k8sLocal.sh`Crea un cluster Kubernetes local con Minikube.



**Última actualización**: Noviembre 12, 2025# Ver logs manualmente para diagnosticar


kubectl get pods -n cattle-system

kubectl logs -f -n cattle-system <pod-name>

```1. Acceder a Rancher UI



---2. **Clusters** → **Import Existing** → **Generic**



## 📚 Referencias

- [Terraform cloud-init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config)
- [Vagrant Provisioning](https://www.vagrantup.com/docs/provisioning)
- [Rancher Installation](https://rancher.com/docs/rancher/v2.8/en/installation/)
- [Minikube Start](https://minikube.sigs.k8s.io/docs/start/)

---

Ver documentación completa en:

**Última actualización**: Noviembre 12, 2025

- [`README.md`](../README.md) - Guía general



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
