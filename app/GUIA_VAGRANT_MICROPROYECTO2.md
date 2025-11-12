# 🚀 GUÍA: Usar Vagrant VM con MicroProyecto2

## 📋 Problema Actual

Tienes dos Vagrantfiles diferentes:
1. **`/ProyectoFinal/Vagrantfile`** - VM con Minikube (k8sLocal)
2. **`/microProyecto2_CloudComputing/Vagrantfile`** - VM antigua con Docker Compose

**Necesitas:** Usar la VM de Minikube PERO con acceso a TODO el código de MicroProyecto2.

---

## ✅ Solución: Carpeta Compartida

La clave es usar **`synced_folder`** para que la VM tenga acceso a todo el proyecto.

---

## 🔧 Paso 1: Actualizar el Vagrantfile Principal

Voy a modificar tu **`/ProyectoFinal/Vagrantfile`** para que:
1. ✅ Monte la carpeta `microProyecto2_CloudComputing` dentro de la VM
2. ✅ Instale todas las dependencias necesarias
3. ✅ Configure Minikube con el perfil `k8sLocal`
4. ✅ Deje todo listo para ejecutar los scripts de despliegue

---

## 📂 Estructura Resultante

```
TU WINDOWS:
D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal\
├── Vagrantfile                    ← Vagrantfile principal
├── create_k8sLocal.sh             ← Script de instalación
└── microProyecto2_CloudComputing/ ← Tu proyecto completo
    ├── quickstart.sh
    ├── scripts/
    ├── k8s/
    ├── frontend/
    ├── microUsers/
    ├── microProducts/
    └── microOrders/

DENTRO DE LA VM:
/home/vagrant/
├── .kube/                         ← Config de kubectl
└── /vagrant/                      ← Carpeta sincronizada
    └── microProyecto2_CloudComputing/ ← Acceso al proyecto
        ├── quickstart.sh          ← Scripts disponibles!
        ├── scripts/
        ├── k8s/
        └── ...
```

---

## 🛠️ Implementación

### Archivo 1: Vagrantfile Actualizado

**Ubicación:** `D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal\Vagrantfile`

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "k8slocal-vm"

  # 💻 Red Bridge (para acceso desde Rancher)
  config.vm.network "public_network", bridge: "Automatic"
  
  # 🌐 Red privada para acceso directo desde Windows
  config.vm.network "private_network", ip: "192.168.56.10"

  # 📦 Carpeta compartida - ESTO ES CLAVE
  # Sincroniza la carpeta actual (ProyectoFinal) completa dentro de /vagrant
  config.vm.synced_folder ".", "/vagrant"

  # 💪 Recursos recomendados (aumentados para Kubernetes)
  config.vm.provider "virtualbox" do |vb|
    vb.name = "k8sLocal-MicroStore"
    vb.memory = 6144      # 6GB RAM (Kubernetes + 4 microservicios + MySQL)
    vb.cpus = 4           # 4 CPUs para mejor rendimiento
  end

  # 🚀 Script de provisión
  config.vm.provision "shell", path: "create_k8sLocal.sh"
  
  # 🔧 Post-provisión: mensaje informativo
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  ✅ VM k8sLocal lista para MicroProyecto2                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📂 Tu proyecto está en: /vagrant/microProyecto2_CloudComputing"
    echo ""
    echo "🚀 Para desplegar tu aplicación:"
    echo "   1. vagrant ssh"
    echo "   2. cd /vagrant/microProyecto2_CloudComputing"
    echo "   3. chmod +x quickstart.sh scripts/*.sh"
    echo "   4. ./quickstart.sh"
    echo ""
    echo "🌐 Acceso desde Windows:"
    echo "   IP VM: 192.168.56.10"
    echo "   Minikube IP: $(minikube ip -p k8sLocal 2>/dev/null || echo 'ejecutar dentro de VM')"
    echo ""
    echo "📊 Rancher puede conectarse a: $(hostname -I | awk '{print $1}')"
    echo ""
  SHELL
end
```

### Archivo 2: Script de Instalación Mejorado

**Ubicación:** `D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal\create_k8sLocal.sh`

*(El script que te voy a dar a continuación reemplaza el actual)*

---

## 🎯 Paso 2: Ejecutar Vagrant

```powershell
# En Windows PowerShell
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal

# Si ya tienes una VM corriendo, destrúyela
vagrant destroy -f

# Levantar la nueva VM
vagrant up

# Esto tarda 10-15 minutos la primera vez:
# - Descarga Ubuntu 22.04
# - Instala Docker, kubectl, Minikube
# - Levanta cluster k8sLocal
# - Deja todo listo
```

---

## 🎯 Paso 3: Desplegar tu Aplicación

```bash
# 1. Conectar a la VM
vagrant ssh

# 2. Ir al proyecto
cd /vagrant/microProyecto2_CloudComputing

# 3. Verificar que todo está ahí
ls -la
# Debes ver: quickstart.sh, scripts/, k8s/, frontend/, microUsers/, etc.

# 4. Dar permisos de ejecución
chmod +x quickstart.sh scripts/*.sh

# 5. Ejecutar despliegue automatizado
./quickstart.sh

# Seleccionar: [1] Minikube (Local)
```

---

## 🌐 Paso 4: Acceder a la Aplicación

### Opción A: Desde dentro de la VM

```bash
# Dentro de la VM
minikube ip -p k8sLocal
# Ejemplo: 192.168.49.2

# Probar:
curl http://192.168.49.2/
```

### Opción B: Desde Windows (Port Forwarding)

```bash
# Dentro de la VM
kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'

# Desde Windows:
# http://192.168.56.10:8080
```

### Opción C: Acceso directo con Minikube Service

```bash
# Dentro de la VM
minikube service frontend -n microstore --url -p k8sLocal

# Te da una URL tipo: http://192.168.49.2:30080
# Puedes acceder desde Windows si configuras routes
```

---

## 🔍 Verificación

### Dentro de la VM

```bash
# Verificar Minikube
minikube status -p k8sLocal

# Verificar kubectl
kubectl config current-context
# Debe mostrar: k8sLocal

# Verificar cluster
kubectl get nodes
# Debe mostrar: k8sLocal Ready

# Verificar que puede construir imágenes
docker ps
eval $(minikube docker-env -p k8sLocal)
docker images
```

---

## 📊 Registrar en Rancher

Una vez que la VM esté corriendo:

```bash
# 1. En Rancher UI (http://localhost:80)
# - Cluster Management → Import Existing
# - Seleccionar "Generic"
# - Nombre: "k8sLocal-MicroStore"
# - Copy el comando

# 2. En la VM
vagrant ssh
cd /vagrant/microProyecto2_CloudComputing

# 3. Ejecutar comando de Rancher
curl --insecure -sfL https://TU-IP-RANCHER/v3/import/xxxx.yaml | kubectl apply -f -

# 4. Esperar 2 minutos
# 5. Refresh Rancher UI - verás el cluster activo
```

---

## 🛠️ Troubleshooting

### Problema: No veo la carpeta /vagrant/microProyecto2_CloudComputing

**Solución:**
```bash
# Dentro de la VM
ls -la /vagrant/

# Si no ves microProyecto2_CloudComputing:
# 1. Salir de la VM
exit

# 2. En Windows, verificar estructura
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal
dir

# Debes tener:
# - Vagrantfile
# - microProyecto2_CloudComputing/ (carpeta)

# 3. Reload VM
vagrant reload
```

### Problema: Minikube no inicia

**Solución:**
```bash
# Dentro de la VM
minikube delete -p k8sLocal
minikube start -p k8sLocal --driver=docker --kubernetes-version=stable

# Si falla con Docker:
sudo systemctl restart docker
sudo usermod -aG docker vagrant
# Salir y reconectar
exit
vagrant ssh
```

### Problema: No puedo construir imágenes

**Solución:**
```bash
# Dentro de la VM
eval $(minikube docker-env -p k8sLocal)

# Verificar
docker ps

# Si falla:
minikube docker-env -p k8sLocal
# Ejecutar los comandos export manualmente
```

---

## 🎓 Comandos Útiles

```bash
# Ver logs de un pod
kubectl logs -f POD-NAME -n microstore

# Ver todos los recursos
kubectl get all -n microstore

# Reiniciar un deployment
kubectl rollout restart deployment/users -n microstore

# Ver IP de Minikube
minikube ip -p k8sLocal

# SSH a nodo de Minikube
minikube ssh -p k8sLocal

# Ver dashboard de Kubernetes
minikube dashboard -p k8sLocal
```

---

## 📈 Ventajas de esta Configuración

1. ✅ **Carpeta sincronizada**: Editas en Windows (VSCode), cambios inmediatos en VM
2. ✅ **Sin copiar archivos**: Todo está siempre actualizado
3. ✅ **Scripts disponibles**: Todos los scripts que creé funcionan directamente
4. ✅ **Fácil debugging**: Puedes ver logs, modificar código, y rebuild
5. ✅ **Compatible con Rancher**: Puedes importar el cluster
6. ✅ **Aislado**: No afecta tu Windows, todo en VM

---

## 🚀 Workflow de Desarrollo

```bash
# En Windows (VSCode)
# Editar: microProyecto2_CloudComputing/frontend/web/views.py

# Guardar cambios (automáticamente en VM por carpeta sincronizada)

# En la VM
vagrant ssh
cd /vagrant/microProyecto2_CloudComputing

# Rebuild solo el servicio modificado
eval $(minikube docker-env -p k8sLocal)
cd frontend
docker build -t microstore-frontend:latest .

# Reiniciar pod
kubectl delete pod -l app=frontend -n microstore

# Ver logs
kubectl logs -f -l app=frontend -n microstore

# Probar cambios
curl http://$(minikube ip -p k8sLocal)/
```

---

## 📚 Siguientes Pasos

1. **Actualizar Vagrantfile** (siguiente archivo que crearé)
2. **Actualizar create_k8sLocal.sh** (siguiente)
3. **Ejecutar `vagrant up`**
4. **Seguir esta guía**
5. **Disfrutar de tu entorno de desarrollo** 🎉

---

**Creado:** Noviembre 7, 2025  
**Versión:** 1.0  
**Propósito:** Integrar MicroProyecto2 con Vagrant VM + Minikube
