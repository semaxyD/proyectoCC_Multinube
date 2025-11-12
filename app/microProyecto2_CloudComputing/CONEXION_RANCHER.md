# 🎯 CONEXIÓN CON RANCHER - Guía Completa

## ❗ ACLARACIÓN IMPORTANTE

**Rancher NO se conecta automáticamente.** Es un paso **MANUAL y OPCIONAL** que haces **DESPUÉS** de tener tu aplicación desplegada.

---

## 📊 Flujo Correcto

```
PASO 1: Desplegar Aplicación
┌─────────────────────────────────────────────────────────┐
│  Vagrant VM + Minikube                                  │
│  ./deploy-in-vm.sh                                      │
│  ✅ Aplicación corriendo en k8sLocal                   │
└─────────────────────────────────────────────────────────┘
              │
              │ La aplicación YA FUNCIONA aquí
              │ Rancher es OPCIONAL
              ▼
PASO 2: Registrar en Rancher (OPCIONAL)
┌─────────────────────────────────────────────────────────┐
│  Rancher Server (Azure VM)                              │
│  http://IP-AZURE-RANCHER:80                            │
│  📋 Copiar comando de registro                         │
└─────────────────────────────────────────────────────────┘
              │
              │ Ejecutar comando en Vagrant VM
              ▼
┌─────────────────────────────────────────────────────────┐
│  kubectl apply -f COMANDO-DE-RANCHER.yaml               │
│  ✅ Cluster k8sLocal ahora visible en Rancher          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 ¿Cuándo y Cómo Conectar con Rancher?

### Situación Actual

Según tu `INFRASTRUCTURE.md`, tu Rancher está en:
- **Ubicación:** VM en Azure
- **Acceso:** `http://IP-PUBLICA-AZURE:80`
- **Versión:** Rancher v2.8.3

### Respuesta Directa a tu Pregunta

**¿En qué momento se conecta con Rancher?**
👉 **NUNCA automáticamente.** Debes hacerlo manualmente DESPUÉS de desplegar.

**¿Cómo se conecta?**
👉 Siguiendo estos pasos:

---

## 🚀 PASOS EXACTOS PARA CONECTAR A RANCHER

### Pre-requisitos

✅ Tu aplicación ya está desplegada en Vagrant VM (k8sLocal)
✅ Rancher está corriendo en Azure VM
✅ Tienes acceso a la IP pública de la VM Azure donde corre Rancher

---

### Paso 1: Acceder a Rancher UI

```
1. Abrir navegador en tu Windows
2. Ir a: http://IP-PUBLICA-AZURE-RANCHER:80

   (Según tu INFRASTRUCTURE.md, debería ser algo como)
   http://20.X.X.X:80  o  http://40.X.X.X:80
```

**Si no recuerdas la IP:**

```bash
# En tu Azure Portal:
# 1. Ir a Virtual Machines
# 2. Buscar la VM donde instalaste Rancher
# 3. Ver "Public IP address"
```

---

### Paso 2: Login a Rancher

```
1. Primera vez:
   - Usuario: admin
   - Contraseña: (la que configuraste en Phase 1)

2. Si olvidaste la contraseña:
   # SSH a la VM Azure de Rancher
   docker logs rancher 2>&1 | grep "Bootstrap Password"
```

---

### Paso 3: Importar Cluster k8sLocal (Vagrant VM)

#### 3.1 En Rancher UI:

```
1. Click en "☰" (menú hamburguesa)
2. Cluster Management
3. Click botón "Import Existing"
4. Seleccionar: "Generic" (o "Other Cluster")
5. Cluster Name: "k8sLocal-Vagrant-Dev"
6. Click "Create"
```

#### 3.2 Copiar Comando de Registro:

Rancher te mostrará algo como:

```bash
curl --insecure -sfL https://IP-RANCHER-AZURE/v3/import/xxxxxxxxxxxxx.yaml | kubectl apply -f -
```

**📋 COPIA este comando completo**

---

### Paso 4: Ejecutar Comando en Vagrant VM

```bash
# En tu Windows PowerShell:
vagrant ssh

# Dentro de la VM:
cd /vagrant/microProyecto2_CloudComputing

# Verificar que kubectl está apuntando a k8sLocal
kubectl config current-context
# Debe mostrar: k8sLocal

# Pegar y ejecutar el comando de Rancher:
curl --insecure -sfL https://IP-RANCHER-AZURE/v3/import/xxxxxxxxxxxxx.yaml | kubectl apply -f -

# Salida esperada:
# clusterrole.rbac.authorization.k8s.io/proxy-clusterrole-kubeapiserver created
# clusterrolebinding.rbac.authorization.k8s.io/proxy-role-binding-kubernetes-master created
# namespace/cattle-system created
# serviceaccount/cattle created
# ...
```

---

### Paso 5: Verificar en Rancher

```
1. Volver a Rancher UI en navegador
2. Cluster Management
3. Esperar 1-2 minutos
4. Refresh página (F5)

5. Deberías ver:
   ┌────────────────────────────────────────┐
   │ k8sLocal-Vagrant-Dev                   │
   │ Status: ⚫ Active                      │
   │ Provider: Imported                     │
   │ Kubernetes: v1.28.x                    │
   │ Nodes: 1                               │
   └────────────────────────────────────────┘
```

---

### Paso 6: Explorar tu Cluster desde Rancher

```
1. En Rancher UI, click en "k8sLocal-Vagrant-Dev"
2. Se abre "Cluster Explorer"
3. Navega a:
   - Workload → Deployments
     • Verás: frontend, users, products, orders
   
   - Workload → Pods
     • Verás todos tus pods corriendo
   
   - Service Discovery → Services
     • Verás tus services
   
   - Storage → PersistentVolumeClaims
     • Verás el PVC de MySQL

4. Puedes:
   - Ver logs de cualquier pod
   - Abrir terminal en pods
   - Ver métricas
   - Escalar deployments
   - Todo desde la UI de Rancher
```

---

## 🎯 Ejemplo Completo Real

### Escenario:
- Rancher en Azure: `http://40.112.45.123:80`
- Vagrant VM con k8sLocal funcionando

### Comandos Reales:

```bash
# 1. En Windows - Abrir navegador
http://40.112.45.123:80

# 2. Login a Rancher
Usuario: admin
Password: tu-password

# 3. Import Existing Cluster → Generic
Nombre: k8sLocal-Vagrant-Dev

# 4. Copiar comando (ejemplo):
curl --insecure -sfL https://40.112.45.123/v3/import/k5qx7t89xxxxx.yaml | kubectl apply -f -

# 5. En PowerShell Windows:
cd D:\Octavo_Semestre\Computacion_En_La_Nube\ProyectoFinal
vagrant ssh

# 6. Dentro de Vagrant VM:
kubectl config use-context k8sLocal

# 7. Ejecutar comando de Rancher:
curl --insecure -sfL https://40.112.45.123/v3/import/k5qx7t89xxxxx.yaml | kubectl apply -f -

# 8. Verificar instalación:
kubectl get pods -n cattle-system

# Salida:
# NAME                               READY   STATUS    RESTARTS   AGE
# cattle-cluster-agent-xxx           1/1     Running   0          1m
# cattle-node-agent-xxx              1/1     Running   0          1m

# 9. Volver a Rancher UI → Refresh → Ver cluster activo
```

---

## 🔍 Troubleshooting Conexión con Rancher

### Problema 1: "No puedo acceder a Rancher UI"

**Causa:** IP incorrecta o puerto bloqueado

**Solución:**
```bash
# Verificar IP de VM Azure con Rancher
# Azure Portal → Virtual Machines → Tu-VM-Rancher → Public IP

# Verificar que Rancher está corriendo
# SSH a VM Azure:
ssh usuario@IP-AZURE-RANCHER
docker ps | grep rancher

# Debe mostrar:
# CONTAINER ID   IMAGE                    STATUS
# xxxxx          rancher/rancher:v2.8.3   Up 3 days

# Verificar puerto 80 abierto
docker logs rancher 2>&1 | tail -20

# Verificar NSG (Network Security Group) en Azure
# Debe permitir puerto 80 desde tu IP
```

---

### Problema 2: "Comando de Rancher falla"

**Error:** `curl: (6) Could not resolve host`

**Solución:**
```bash
# Dentro de Vagrant VM
# Verificar conectividad a Rancher
ping IP-RANCHER-AZURE

# Si no hay ping, verificar red de Vagrant
# En Vagrantfile debe tener:
config.vm.network "public_network"
# o
config.vm.network "private_network", ip: "192.168.56.10"

# Reload VM
exit
vagrant reload
vagrant ssh
```

---

### Problema 3: "Cluster aparece como 'Unavailable' en Rancher"

**Causa:** Agente de Rancher no puede comunicarse de vuelta

**Solución:**
```bash
# Dentro de Vagrant VM
kubectl get pods -n cattle-system

# Si pods están en CrashLoopBackOff:
kubectl logs -n cattle-system POD-NAME

# Verificar que Rancher puede alcanzar la VM
# La VM necesita ser accesible desde Azure

# Opción 1: Usar IP pública de Vagrant VM
hostname -I
# Configurar port forwarding o VPN

# Opción 2: Usar Rancher en local (no en Azure)
# Para desarrollo, más fácil tener Rancher en tu PC
```

---

### Problema 4: "Cluster registrado pero no veo workloads"

**Causa:** Namespace no seleccionado

**Solución:**
```
1. En Rancher UI → Cluster Explorer
2. Arriba a la derecha, verificar namespace
3. Cambiar de "default" a "microstore"
4. O seleccionar "All Namespaces"
```

---

## 📊 Comparación: Con Rancher vs Sin Rancher

### Sin Rancher (Actual)

```bash
# Gestión directa con kubectl
kubectl get pods -n microstore
kubectl logs frontend-xxx -n microstore
kubectl scale deployment frontend --replicas=3 -n microstore
kubectl port-forward svc/frontend 8080:5000 -n microstore
```

**Ventajas:**
- ✅ Simple
- ✅ Rápido
- ✅ No depende de servicios externos

**Desventajas:**
- ❌ Solo línea de comandos
- ❌ Difícil de compartir con equipo
- ❌ No hay vista centralizada de múltiples clusters

---

### Con Rancher (Después de Registrar)

```
# UI Web centralizada
http://IP-RANCHER:80
→ Cluster Explorer → k8sLocal-Vagrant-Dev
→ Click, click, click (todo visual)
```

**Ventajas:**
- ✅ UI visual bonita
- ✅ Múltiples clusters en un lugar
- ✅ Control de acceso (RBAC)
- ✅ Monitoreo integrado
- ✅ Fácil para demos/presentaciones

**Desventajas:**
- ❌ Configuración adicional
- ❌ Depende de Rancher disponible
- ❌ Más complejo para troubleshooting

---

## 🎓 Recomendación para tu Proyecto

### Para Desarrollo (Ahora)

**NO necesitas Rancher todavía.**

```bash
# Workflow actual (suficiente):
1. vagrant up
2. vagrant ssh
3. cd /vagrant/microProyecto2_CloudComputing
4. ./deploy-in-vm.sh
5. kubectl get pods -n microstore
6. Probar aplicación
7. Desarrollar, modificar, rebuild
```

---

### Para Presentación/Sustentación

**SÍ, usa Rancher para impresionar.**

```
1. Registrar k8sLocal (Vagrant) en Rancher
2. Registrar AKS (Azure) en Rancher
3. En presentación, mostrar:
   - Dashboard de Rancher
   - Múltiples clusters gestionados
   - Vista unificada
   - Métricas y monitoreo
```

**Impacto en Presentación:** 📈📈📈

Profesores verán:
- ✅ Gestión profesional de clusters
- ✅ Multi-cloud (local + Azure)
- ✅ Herramientas enterprise
- ✅ Escalabilidad

---

## 📝 Checklist: Cuándo Conectar a Rancher

### Momento Ideal: **2-3 días antes de sustentar**

- [ ] Aplicación funciona perfectamente en Vagrant VM
- [ ] Aplicación funciona perfectamente en Azure AKS
- [ ] Rancher está accesible en Azure VM
- [ ] Tienes tiempo para troubleshooting
- [ ] Practicarás demo varias veces

### No es el Momento: **Durante desarrollo activo**

- [ ] Estás probando código nuevo
- [ ] Cambiando configuraciones frecuentemente
- [ ] Debugging errores
- [ ] Aprendiendo Kubernetes

---

## 🚀 Siguiente Paso AHORA

**Opción A: Sin Rancher (Recomendado para ahora)**

```bash
# Continúa desarrollando
kubectl get all -n microstore
kubectl logs -f -l app=frontend -n microstore

# Probar aplicación
curl http://$(minikube ip -p k8sLocal)/

# Port forward para acceso desde Windows
kubectl port-forward -n microstore svc/frontend 8080:5000 --address='0.0.0.0'

# Abrir en Windows: http://192.168.56.10:8080
```

---

**Opción B: Conectar a Rancher (Si quieres probar ahora)**

```bash
# 1. Obtener IP de Rancher
# (Azure Portal → Tu VM Rancher → Public IP)

# 2. Abrir navegador
http://IP-RANCHER:80

# 3. Login → Import Cluster → Copiar comando

# 4. En Vagrant VM:
kubectl config use-context k8sLocal
# Pegar comando de Rancher

# 5. Verificar en Rancher UI
```

---

## 📚 Comandos de Referencia Rápida

### Verificar Conectividad a Rancher

```bash
# Desde Vagrant VM
ping IP-RANCHER-AZURE
curl -I http://IP-RANCHER-AZURE:80

# Debe devolver: HTTP/1.1 ...
```

### Verificar Registro en Rancher

```bash
# Dentro de Vagrant VM
kubectl get pods -n cattle-system

# Si hay pods, está registrado
# Si está vacío, no está registrado
```

### Ver Logs del Agente de Rancher

```bash
kubectl logs -n cattle-system -l app=cattle-cluster-agent
kubectl logs -n cattle-system -l app=cattle-node-agent
```

### Desregistrar de Rancher

```bash
# Si quieres empezar de nuevo
kubectl delete namespace cattle-system
kubectl delete clusterrole cattle-admin
kubectl delete clusterrolebinding cattle-admin-binding
```

---

## ✅ Resumen Final

| Pregunta | Respuesta |
|----------|-----------|
| ¿Cuándo se conecta con Rancher? | **Manualmente, DESPUÉS de desplegar** |
| ¿Es obligatorio? | **NO** - Aplicación funciona sin Rancher |
| ¿Cómo se conecta? | **Copiar comando de Rancher UI → ejecutar en VM** |
| ¿Dónde está Rancher? | **Azure VM con IP pública** |
| ¿Necesito hacerlo ahora? | **NO** - Mejor 2-3 días antes de sustentar |
| ¿Puedo desarrollar sin Rancher? | **SÍ** - Usa kubectl directamente |

---

## 🎯 Tu Situación Actual

```
✅ Lo que tienes:
   - Vagrant VM corriendo
   - Minikube (k8sLocal) funcionando
   - Aplicación desplegada (o desplegándose)
   - kubectl funcionando

❓ Rancher:
   - Está en Azure VM
   - NO conectado todavía
   - NO necesitas conectarlo ahora
   - Conéctalo cuando practiques demo final
```

---

**Creado:** Noviembre 7, 2025  
**Versión:** 1.0  
**Propósito:** Aclarar conexión con Rancher - Manual y Opcional
