# 🎯 PASOS EXACTOS PARA EJECUTAR TODO

## 📋 Resumen Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                     TU COMPUTADORA WINDOWS                       │
│                                                                  │
│  Carpeta: D:\...\ProyectoFinal\                                │
│  ├── Vagrantfile            ✅ Actualizado                      │
│  ├── create_k8sLocal.sh     ✅ Actualizado                      │
│  └── microProyecto2_CloudComputing/                             │
│      ├── deploy-in-vm.sh    ✅ Nuevo                            │
│      ├── quickstart.sh                                          │
│      ├── scripts/                                               │
│      ├── k8s/                                                   │
│      └── [todos tus microservicios]                            │
│                                                                  │
│      ↓ vagrant up                                               │
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │          VAGRANT VM (VirtualBox)                      │      │
│  │          Ubuntu 22.04 + Minikube                      │      │
│  │                                                        │      │
│  │  /vagrant/ ← carpeta sincronizada                    │      │
│  │  └── microProyecto2_CloudComputing/                  │      │
│  │                                                        │      │
│  │  Cluster: k8sLocal                                    │      │
│  │  ├── namespace: microstore                            │      │
│  │  ├── frontend (pod)                                   │      │
│  │  ├── users (pod)                                      │      │
│  │  ├── products (pod)                                   │      │
│  │  ├── orders (pod)                                     │      │
│  │  └── mysql (statefulset)                              │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚡ PASO A PASO (COPIA Y PEGA)

### 🔴 Paso 1: Preparar Archivos (YA ESTÁ LISTO)

Los archivos ya fueron actualizados:
- ✅ `Vagrantfile` actualizado
- ✅ `create_k8sLocal.sh` actualizado
- ✅ `deploy-in-vm.sh` creado
- ✅ Documentación completa creada

---

### 🟡 Paso 2: Abrir PowerShell en Windows

```powershell
# Presiona: Windows + X
# Selecciona: Windows PowerShell

# Navegar a la carpeta del proyecto
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal

# Verificar que estás en el lugar correcto
dir
# Debes ver:
#   - Vagrantfile
#   - create_k8sLocal.sh
#   - microProyecto2_CloudComputing (carpeta)
```

---

### 🟢 Paso 3: Destruir VM Antigua (Si existe)

```powershell
# Esto elimina cualquier VM anterior
vagrant destroy -f

# Si no hay VM anterior, verás un error - ESTÁ BIEN, continúa
```

---

### 🔵 Paso 4: Levantar la Nueva VM

```powershell
# Este comando tarda 10-15 minutos la primera vez
vagrant up
```

**¿Qué hace esto?**
- ✅ Descarga Ubuntu 22.04 (si no lo tienes)
- ✅ Crea VM con 6GB RAM y 4 CPUs
- ✅ Ejecuta `create_k8sLocal.sh` automáticamente:
  - Instala Docker
  - Instala kubectl
  - Instala Minikube
  - Levanta cluster k8sLocal
  - Configura networking
  - Habilita Ingress, metrics-server, dashboard

**Salida esperada al final:**
```
╔═══════════════════════════════════════════════════════════╗
║  ✅ VM k8sLocal lista para MicroProyecto2                ║
╚═══════════════════════════════════════════════════════════╝

📂 Tu proyecto está en: /vagrant/microProyecto2_CloudComputing

🚀 QUICK START - Para desplegar tu aplicación:
   1. vagrant ssh
   2. cd /vagrant/microProyecto2_CloudComputing
   3. ./quickstart.sh
```

---

### 🟣 Paso 5: Conectar a la VM

```powershell
vagrant ssh
```

**Ahora estás dentro de la VM Ubuntu.**  
Tu prompt cambiará a algo como: `vagrant@k8slocal-vm:~$`

---

### 🟠 Paso 6: Verificar que Todo Funciona

```bash
# Verificar Minikube
minikube status -p k8sLocal

# Salida esperada:
# k8sLocal
# type: Control Plane
# host: Running
# kubelet: Running
# apiserver: Running

# Verificar kubectl
kubectl get nodes

# Salida esperada:
# NAME       STATUS   ROLES           AGE   VERSION
# k8sLocal   Ready    control-plane   5m    v1.28.0

# Verificar carpeta del proyecto
ls /vagrant/microProyecto2_CloudComputing

# Debes ver todos tus archivos y carpetas
```

**✅ Si todo esto funciona, ¡estás listo!**

---

### 🔷 Paso 7: Desplegar la Aplicación

```bash
# Ir a la carpeta del proyecto
cd /vagrant/microProyecto2_CloudComputing

# Opción A: Script Interactivo (RECOMENDADO para primera vez)
./deploy-in-vm.sh

# El script:
# 1. Verifica prerequisitos
# 2. Te pregunta si quieres desplegar
# 3. Si dices 's' (sí), despliega todo automáticamente
# 4. Construye las 4 imágenes Docker
# 5. Despliega MySQL y microservicios
# 6. Configura Ingress
# 7. Te da las URLs de acceso
```

**O usar:**

```bash
# Opción B: Script Directo
./quickstart.sh

# Seleccionar: [1] Minikube (Local)
```

**O usar:**

```bash
# Opción C: Script específico de Minikube
./scripts/deploy-minikube.sh
```

**Tiempo estimado:** 5-10 minutos (construye imágenes y despliega)

---

### 🔶 Paso 8: Esperar y Ver Progreso

```bash
# Ver pods en tiempo real
kubectl get pods -n microstore -w

# Esperar hasta que todos estén en estado Running:
# NAME                        READY   STATUS    RESTARTS   AGE
# frontend-xxxxx-yyyyy       1/1     Running   0          2m
# mysql-0                    1/1     Running   0          3m
# orders-xxxxx-yyyyy         1/1     Running   0          2m
# products-xxxxx-yyyyy       1/1     Running   0          2m
# users-xxxxx-yyyyy          1/1     Running   0          2m

# Presiona Ctrl+C para salir del watch
```

---

### 🟤 Paso 9: Obtener URLs de Acceso

```bash
# Obtener IP de Minikube
minikube ip -p k8sLocal

# Ejemplo de salida: 192.168.49.2
```

**URLs de tu aplicación:**
- Frontend: `http://192.168.49.2/`
- API Users: `http://192.168.49.2/users`
- API Products: `http://192.168.49.2/products`
- API Orders: `http://192.168.49.2/orders`

---

### ⚫ Paso 10: Probar la Aplicación

#### Desde Dentro de la VM

```bash
# Dentro de la VM
curl http://$(minikube ip -p k8sLocal)/

# Debería devolver HTML del frontend

# Probar API de usuarios
curl http://$(minikube ip -p k8sLocal)/users

# Probar API de productos
curl http://$(minikube ip -p k8sLocal)/products
```

#### Desde Windows (Navegador)

**Opción 1: Port Forwarding (MÁS FÁCIL)**

```bash
# Dentro de la VM, ejecutar:
kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'

# Dejar este comando corriendo (NO presionar Ctrl+C)
```

**Ahora en Windows:**
1. Abrir navegador (Chrome, Edge, Firefox)
2. Ir a: `http://192.168.56.10:8080`
3. Deberías ver tu aplicación MicroStore

**Opción 2: Acceso Directo (requiere más configuración)**

En Windows, abrir navegador y probar:
- `http://MINIKUBE-IP/` (la IP que obtuviste en Paso 9)

Nota: Esto puede no funcionar directamente debido al routing de red.  
**Recomendación: Usar Opción 1 (Port Forwarding)**

---

## 🎉 ¡LISTO!

Tu aplicación ahora está corriendo en:
- ✅ VM Vagrant (Ubuntu)
- ✅ Minikube (Kubernetes)
- ✅ Cluster k8sLocal
- ✅ Namespace microstore
- ✅ 4 microservicios + MySQL

---

## 📊 Comandos Útiles para Trabajar

### Ver Estado de Todo

```bash
# Dentro de la VM
kubectl get all -n microstore

# Ver solo pods
kubectl get pods -n microstore

# Ver services
kubectl get svc -n microstore

# Ver logs de un servicio
kubectl logs -f -l app=frontend -n microstore

# Dashboard de Kubernetes (abre en navegador)
minikube dashboard -p k8sLocal
```

### Modificar Código y Rebuild

```bash
# 1. En Windows, editar código en VSCode
#    Ejemplo: frontend/web/views.py

# 2. Dentro de la VM, configurar Docker
cd /vagrant/microProyecto2_CloudComputing
eval $(minikube docker-env -p k8sLocal)

# 3. Rebuild solo el servicio modificado
cd frontend
docker build -t microstore-frontend:latest .
cd ..

# 4. Reiniciar pod para usar nueva imagen
kubectl delete pod -l app=frontend -n microstore

# 5. Ver logs del nuevo pod
kubectl logs -f -l app=frontend -n microstore

# 6. Probar cambios
curl http://$(minikube ip -p k8sLocal)/
```

### Limpiar y Redesplegar

```bash
# Eliminar todo
kubectl delete namespace microstore

# Redesplegar
cd /vagrant/microProyecto2_CloudComputing
./deploy-in-vm.sh
```

---

## 🛑 Apagar Todo

### Salir de la VM

```bash
# Dentro de la VM
exit
```

### Apagar la VM (desde Windows)

```powershell
# En PowerShell
vagrant halt

# O destruir completamente
vagrant destroy -f
```

---

## 🔄 Próximas Veces (Workflow Rápido)

```powershell
# En Windows PowerShell
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal

# Levantar VM (si está apagada)
vagrant up

# Conectar
vagrant ssh

# Dentro de VM
cd /vagrant/microProyecto2_CloudComputing

# Si ya desplegaste antes, solo verifica:
kubectl get pods -n microstore

# Si quieres redesplegar:
./deploy-in-vm.sh
```

---

## 🐛 Si Algo Sale Mal

### Error: "No se encuentra la carpeta"

```bash
# Dentro de VM
ls /vagrant/

# Si no ves microProyecto2_CloudComputing:
exit

# En Windows
vagrant reload
vagrant ssh
```

### Error: "Minikube no inicia"

```bash
# Dentro de VM
minikube delete -p k8sLocal
sudo systemctl restart docker
minikube start -p k8sLocal --driver=docker
```

### Error: "Pods en ImagePullBackOff"

```bash
# Dentro de VM
cd /vagrant/microProyecto2_CloudComputing
eval $(minikube docker-env -p k8sLocal)
./deploy-in-vm.sh
```

### Leer Documentación Completa

```bash
# Dentro de VM
cat /vagrant/GUIA_VAGRANT_MICROPROYECTO2.md

# O desde Windows en VSCode:
# Abrir: D:\...\ProyectoFinal\GUIA_VAGRANT_MICROPROYECTO2.md
```

---

## 📚 Archivos Importantes

| Archivo | Ubicación | Propósito |
|---------|-----------|-----------|
| `Vagrantfile` | ProyectoFinal/ | Configuración de la VM |
| `create_k8sLocal.sh` | ProyectoFinal/ | Script de instalación |
| `deploy-in-vm.sh` | microProyecto2_CloudComputing/ | Despliegue en VM |
| `quickstart.sh` | microProyecto2_CloudComputing/ | Script interactivo |
| `README_VAGRANT.md` | ProyectoFinal/ | Guía rápida |
| `GUIA_VAGRANT_MICROPROYECTO2.md` | ProyectoFinal/ | Guía completa |

---

## ✅ Checklist Final

Antes de considerar que todo funciona, verifica:

- [ ] `vagrant status` → running
- [ ] `vagrant ssh` → conecta sin errores
- [ ] `minikube status -p k8sLocal` → Running
- [ ] `kubectl get nodes` → k8sLocal Ready
- [ ] `ls /vagrant/microProyecto2_CloudComputing` → muestra archivos
- [ ] `kubectl get pods -n microstore` → todos Running
- [ ] `curl http://$(minikube ip -p k8sLocal)/` → devuelve HTML
- [ ] Port forward funciona → `http://192.168.56.10:8080` accesible

---

## 🎯 Siguiente: Registrar en Rancher

Una vez que todo funcione en la VM, puedes registrar el cluster en Rancher:

1. Abrir Rancher UI: `http://localhost:80`
2. Cluster Management → Import Existing
3. Seleccionar "Generic"
4. Nombre: "k8sLocal-VM"
5. Copiar comando
6. Dentro de la VM: pegar y ejecutar el comando
7. Esperar 2 minutos
8. Refresh Rancher UI

Ahora puedes gestionar tu cluster k8sLocal desde Rancher! 🎉

---

**Creado:** Noviembre 7, 2025  
**Versión:** 1.0  
**Propósito:** Guía paso a paso para ejecutar MicroProyecto2 en Vagrant VM
