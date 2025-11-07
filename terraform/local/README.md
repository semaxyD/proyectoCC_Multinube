# 🖥️ Cluster Local con Vagrant + Minikube

Este módulo crea una máquina virtual local con VirtualBox y aprovisiona un cluster de Kubernetes con Minikube.

> ⚠️ **Nota Importante**: Este directorio está en `terraform/local/` pero **NO** usa Terraform.  
> Usa **Vagrant** para crear la VM local porque:
> - Terraform no puede gestionar VMs locales con VirtualBox directamente
> - Vagrant es la herramienta estándar para VMs locales de desarrollo
> - Mantiene consistencia con el resto del proyecto (infraestructura como código)

## 📋 Prerrequisitos

1. **VirtualBox** instalado:
   ```powershell
   # Descargar desde: https://www.virtualbox.org/wiki/Downloads
   # O con Chocolatey:
   choco install virtualbox
   ```

2. **Vagrant** instalado:
   ```powershell
   # Descargar desde: https://www.vagrantup.com/downloads
   # O con Chocolatey:
   choco install vagrant
   ```

3. **Recursos del sistema**:
   - Mínimo 4 GB RAM disponibles
   - 2 CPU cores disponibles
   - ~10 GB de espacio en disco

## 🚀 Uso Rápido

### 1. Crear la VM y el Cluster

```powershell
# Desde el directorio terraform/local/
vagrant up
```

Esto realizará automáticamente:
- ✅ Descarga la box de Ubuntu 22.04
- ✅ Crea la VM con 4GB RAM y 2 CPUs
- ✅ Configura red bridge (preguntará qué adaptador usar)
- ✅ Ejecuta el script `create-k8sLocal.sh`
- ✅ Instala Docker, kubectl y Minikube
- ✅ Crea el cluster de Kubernetes

**Tiempo estimado**: 5-10 minutos (primera vez)

### 2. Conectarse a la VM

```powershell
vagrant ssh
```

### 3. Verificar el Cluster

Desde dentro de la VM:
```bash
# Ver nodos
kubectl get nodes

# Ver pods del sistema
kubectl get pods -A

# Ver información de Minikube
minikube status
```

O desde el host:
```powershell
vagrant ssh -c "kubectl get nodes"
```

## 🛠️ Comandos Útiles

### Gestión de la VM

```powershell
# Ver estado de la VM
vagrant status

# Detener la VM (sin eliminarla)
vagrant halt

# Reiniciar la VM
vagrant reload

# Eliminar la VM completamente
vagrant destroy

# Ver SSH config
vagrant ssh-config
```

### Acceder a Minikube

```powershell
# SSH a la VM
vagrant ssh

# Dentro de la VM:
minikube status
minikube dashboard  # Abrir dashboard de Kubernetes
minikube service <service-name>  # Exponer un servicio
```

### Re-provisionar

Si necesitas re-ejecutar el script de aprovisionamiento:

```powershell
vagrant provision
```

## 📂 Estructura de Archivos

```
terraform/local/
├── Vagrantfile           # Configuración de Vagrant
└── README.md            # Esta documentación

../../scripts/
└── create-k8sLocal.sh   # Script de aprovisionamiento de Minikube
```

## 🔧 Configuración Personalizada

### Cambiar Recursos de la VM

Edita el `Vagrantfile`:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "8192"  # 8 GB RAM
  vb.cpus = 4         # 4 CPUs
end
```

### Cambiar Adaptador de Red

Por defecto intenta conectarse a:
- MediaTek Wi-Fi SE MT7902
- Intel(R) Ethernet Connection
- Realtek PCIe GbE Family Controller

Si tu adaptador es diferente, edita:

```ruby
config.vm.network "public_network", bridge: "Tu-Adaptador-Aqui"
```

Para ver tus adaptadores:
```powershell
Get-NetAdapter | Select-Object Name, InterfaceDescription
```

## 📊 Registrar en Rancher

Una vez creado el cluster, regístralo manualmente desde la UI de Rancher:

### Paso 1: Crear importación en Rancher UI

1. Acceder a Rancher: `https://<RANCHER_IP>`
2. Ir a **Clusters** → **Import Existing**
3. Seleccionar **"Generic"**
4. Nombrar el cluster: `k8sLocal`
5. Agregar descripción (opcional)
6. Click **"Create"**

### Paso 2: Aplicar configuración en el cluster

Rancher mostrará un comando similar a:
```bash
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -
```

Ejecutarlo dentro de la VM:

```powershell
# Conectarse a la VM
vagrant ssh

# Ejecutar comando de Rancher
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -

# Verificar registro
kubectl get namespace cattle-system
kubectl get pods -n cattle-system
```

### Paso 3: Verificar en Rancher UI

El cluster debe aparecer como **Active** en 2-3 minutos.

## 🐛 Troubleshooting

### La VM no inicia

```powershell
# Ver logs detallados
vagrant up --debug

# Verificar que VirtualBox funciona
VBoxManage --version

# Verificar virtualización habilitada en BIOS
```

### Error de red bridge

```powershell
# Vagrant preguntará qué adaptador usar
# Selecciona tu adaptador de red activo (WiFi o Ethernet)

# O especifica uno en Vagrantfile:
config.vm.network "public_network", bridge: "Nombre-Adaptador"
```

### Minikube no inicia

```bash
# SSH a la VM
vagrant ssh

# Ver logs de Minikube
minikube logs

# Reiniciar Minikube
minikube delete
minikube start --driver=docker
```

### Falta espacio en disco

```powershell
# Ver uso de disco de VMs
VBoxManage list systemproperties | findstr "Default machine folder"

# Cambiar ubicación de VMs de VirtualBox (en VirtualBox UI):
# File → Preferences → General → Default Machine Folder
```

## 💡 Ventajas vs Desventajas

### ✅ Ventajas
- No requiere conexión a internet después de la descarga inicial
- Ambiente completamente aislado
- Fácil de resetear (`vagrant destroy && vagrant up`)
- Usa recursos reales de tu máquina
- Compatible con cualquier OS que soporte VirtualBox

### ⚠️ Desventajas
- Consume recursos locales (4 GB RAM)
- No simula un cluster distribuido real
- Requiere virtualización habilitada en BIOS
- Más lento que soluciones nativas en Linux

## 🔗 Recursos

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Script de creación: create-k8sLocal.sh](../../scripts/create-k8sLocal.sh)

## 📝 Notas

- El script `create-k8sLocal.sh` es ejecutado automáticamente por Vagrant
- La VM tiene acceso bidireccional con tu máquina host
- Los cambios en la VM NO persisten después de `vagrant destroy`
- Para desarrollo persistente, considera usar volúmenes compartidos

---

**Próximo paso**: [Registrar cluster en Rancher](../../docs/rancher-registration.md)
