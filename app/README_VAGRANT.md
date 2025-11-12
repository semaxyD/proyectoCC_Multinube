# 🚀 INICIO RÁPIDO - Vagrant VM con MicroProyecto2

## ⚡ Quick Start (3 pasos)

```powershell
# En Windows PowerShell - Carpeta: ProyectoFinal
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal

# Paso 1: Destruir VM antigua (si existe)
vagrant destroy -f

# Paso 2: Levantar VM nueva (10-15 minutos primera vez)
vagrant up

# Paso 3: Conectar y desplegar
vagrant ssh
cd /vagrant/microProyecto2_CloudComputing
./deploy-in-vm.sh
```

¡Listo! Tu aplicación estará corriendo en Minikube dentro de la VM.

---

## 📋 ¿Qué incluye esta configuración?

### ✅ Vagrantfile actualizado
- **Ubuntu 22.04** como base
- **6GB RAM** y **4 CPUs** (para K8s + microservicios)
- **Red privada:** `192.168.56.10` (acceso desde Windows)
- **Port forwarding:** Puerto 8080 (para frontend)
- **Carpeta sincronizada:** Todo `/ProyectoFinal` se monta en `/vagrant`

### ✅ Script de instalación (create_k8sLocal.sh)
- Instala Docker, kubectl, Minikube
- Configura networking para Kubernetes
- Levanta cluster `k8sLocal`
- Habilita addons (Ingress, metrics-server, dashboard)
- Configura aliases útiles

### ✅ Script de despliegue (deploy-in-vm.sh)
- Verifica prerequisitos
- Configura Docker para Minikube
- Construye imágenes localmente
- Despliega aplicación completa
- Muestra URLs de acceso

---

## 📁 Estructura del Proyecto

```
ProyectoFinal/
├── Vagrantfile                        ← VM configuration
├── create_k8sLocal.sh                 ← Provisioning script
├── GUIA_VAGRANT_MICROPROYECTO2.md     ← Documentación completa
└── microProyecto2_CloudComputing/     ← Tu proyecto
    ├── deploy-in-vm.sh                ← Script de despliegue en VM
    ├── quickstart.sh                  ← Script interactivo
    ├── scripts/
    │   ├── deploy-minikube.sh         ← Despliegue Minikube
    │   └── deploy-aks.sh              ← Despliegue Azure
    ├── k8s/                           ← Manifiestos K8s
    ├── frontend/                      ← Microservicio frontend
    ├── microUsers/                    ← Microservicio users
    ├── microProducts/                 ← Microservicio products
    └── microOrders/                   ← Microservicio orders
```

---

## 🔄 Workflow Completo

### Primera Vez

```powershell
# 1. Desde Windows - Levantar VM
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal
vagrant up
# ☕ Esperar 10-15 minutos (instala todo)

# 2. Conectar a VM
vagrant ssh

# 3. Verificar que todo está bien
minikube status -p k8sLocal
kubectl get nodes
# Debe mostrar: k8sLocal Ready

# 4. Ir al proyecto
cd /vagrant/microProyecto2_CloudComputing
ls -la
# Debes ver todos tus archivos

# 5. Desplegar aplicación
./deploy-in-vm.sh
# o
./quickstart.sh
# Seleccionar: [1] Minikube (Local)

# 6. Esperar 5-10 minutos
# ☕ El script construye imágenes y despliega todo

# 7. Ver resultado
kubectl get pods -n microstore
# Todos deben estar Running

# 8. Obtener IP
minikube ip -p k8sLocal
# Ejemplo: 192.168.49.2

# 9. Probar aplicación
curl http://192.168.49.2/
```

### Acceder desde Windows

```powershell
# Opción 1: Port Forwarding (RECOMENDADO)
# Dentro de la VM:
kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'

# Desde Windows - Abrir navegador:
http://192.168.56.10:8080
```

```powershell
# Opción 2: Acceso directo (requiere configuración adicional)
# Desde Windows:
http://MINIKUBE-IP/
# Nota: Puede requerir configurar rutas
```

---

## 🛠️ Desarrollo Diario

### Modificar Código

```powershell
# En Windows (VSCode)
# Editar: D:\...\ProyectoFinal\microProyecto2_CloudComputing\frontend\web\views.py
# Guardar cambios

# Los cambios se sincronizan automáticamente en /vagrant/
```

### Rebuild y Redeploy

```bash
# Dentro de la VM
cd /vagrant/microProyecto2_CloudComputing

# Configurar Docker para Minikube
eval $(minikube docker-env -p k8sLocal)

# Rebuild solo el servicio modificado
cd frontend
docker build -t microstore-frontend:latest .
cd ..

# Reiniciar pods para usar nueva imagen
kubectl delete pod -l app=frontend -n microstore

# Ver logs
kubectl logs -f -l app=frontend -n microstore

# Probar
curl http://$(minikube ip -p k8sLocal)/
```

---

## 🔍 Comandos Útiles

### Gestión de VM

```powershell
# Ver estado
vagrant status

# Conectar
vagrant ssh

# Apagar VM
vagrant halt

# Reiniciar VM
vagrant reload

# Destruir VM
vagrant destroy -f

# Re-provisionar (re-ejecutar scripts)
vagrant reload --provision
```

### Dentro de la VM

```bash
# Ver cluster
kubectl get nodes
kubectl cluster-info

# Ver aplicación
kubectl get all -n microstore
kubectl get pods -n microstore -w

# Ver logs
kubectl logs -f POD-NAME -n microstore
kubectl logs -f -l app=frontend -n microstore

# Describir recursos
kubectl describe pod POD-NAME -n microstore
kubectl describe svc frontend -n microstore

# Dashboard de Kubernetes
minikube dashboard -p k8sLocal

# IP de Minikube
minikube ip -p k8sLocal

# SSH a nodo de Minikube
minikube ssh -p k8sLocal

# Ver imágenes en Minikube
eval $(minikube docker-env -p k8sLocal)
docker images | grep microstore
```

### Aliases Configurados

```bash
# Estos aliases ya están configurados en la VM:
k                 # kubectl
kgp               # kubectl get pods -A
kgs               # kubectl get svc -A
mk                # minikube -p k8sLocal
mke               # eval $(minikube docker-env -p k8sLocal)
```

---

## 🐛 Troubleshooting

### Problema: "No veo /vagrant/microProyecto2_CloudComputing"

```bash
# Dentro de VM
ls -la /vagrant/

# Si no ves la carpeta:
exit

# En Windows
vagrant reload

# Verificar en Windows que existe:
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal
dir
# Debe haber una carpeta: microProyecto2_CloudComputing
```

### Problema: "Minikube no inicia"

```bash
# Dentro de VM
minikube delete -p k8sLocal
sudo systemctl restart docker
minikube start -p k8sLocal --driver=docker --kubernetes-version=stable
```

### Problema: "No puedo construir imágenes"

```bash
# Configurar Docker para Minikube
eval $(minikube docker-env -p k8sLocal)

# Verificar
docker ps

# Si falla, reiniciar Minikube
minikube stop -p k8sLocal
minikube start -p k8sLocal
eval $(minikube docker-env -p k8sLocal)
```

### Problema: "Pods en ImagePullBackOff"

```bash
# Esto pasa si construiste imágenes ANTES de configurar Docker para Minikube

# Solución:
eval $(minikube docker-env -p k8sLocal)

# Rebuild TODAS las imágenes
cd /vagrant/microProyecto2_CloudComputing
./scripts/deploy-minikube.sh
```

### Problema: "No puedo acceder desde Windows"

```bash
# Solución: Port Forwarding
kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'

# Desde Windows:
http://192.168.56.10:8080
```

---

## 📊 Monitoreo

### Ver Estado General

```bash
# Pods
kubectl get pods -n microstore

# Services
kubectl get svc -n microstore

# Deployments
kubectl get deployments -n microstore

# StatefulSets (MySQL)
kubectl get statefulsets -n microstore

# PVC (almacenamiento)
kubectl get pvc -n microstore

# Todo junto
kubectl get all -n microstore
```

### Ver Recursos del Cluster

```bash
# Uso de recursos por nodo
kubectl top nodes

# Uso de recursos por pod
kubectl top pods -n microstore

# Eventos del cluster
kubectl get events -n microstore --sort-by='.lastTimestamp'
```

---

## 🎯 Registrar en Rancher

```bash
# 1. En Rancher UI (http://localhost:80)
#    - Cluster Management → Import Existing
#    - Generic → Nombre: "k8sLocal-VM"
#    - Copy comando

# 2. Obtener IP pública de la VM
# Dentro de VM:
hostname -I
# Ejemplo: 192.168.56.10 10.0.2.15

# 3. Ejecutar comando de Rancher
# Dentro de VM:
curl --insecure -sfL https://TU-IP-RANCHER/v3/import/xxxx.yaml | kubectl apply -f -

# 4. Esperar 2 minutos
# 5. Refresh Rancher UI - cluster aparecerá
```

---

## 📚 Documentación Adicional

- **GUIA_VAGRANT_MICROPROYECTO2.md** - Guía completa y detallada
- **GUIA_RANCHER_COMPLETA.md** - Cómo usar Rancher
- **TROUBLESHOOTING.md** - Solución a problemas comunes
- **GUIA_DESPLIEGUE_COMPLETA.md** - Despliegue paso a paso

---

## ✅ Checklist de Éxito

- [ ] VM levantada: `vagrant status` → running
- [ ] Minikube corriendo: `minikube status -p k8sLocal` → Running
- [ ] Cluster listo: `kubectl get nodes` → k8sLocal Ready
- [ ] Proyecto accesible: `ls /vagrant/microProyecto2_CloudComputing`
- [ ] Aplicación desplegada: `kubectl get pods -n microstore` → todos Running
- [ ] Acceso desde Windows: `http://192.168.56.10:8080` funciona

---

## 🎓 Resumen

**Lo que tienes ahora:**
- ✅ VM Ubuntu con Kubernetes (Minikube)
- ✅ Todo el código sincronizado automáticamente
- ✅ Scripts automatizados de despliegue
- ✅ Entorno aislado para desarrollo
- ✅ Compatible con Rancher
- ✅ Port forwarding para acceso desde Windows

**Siguiente paso:**
```bash
vagrant up && vagrant ssh
cd /vagrant/microProyecto2_CloudComputing
./deploy-in-vm.sh
```

🚀 **¡A trabajar!**
