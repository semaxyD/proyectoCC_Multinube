# 🔧 TROUBLESHOOTING - GUÍA COMPLETA DE SOLUCIÓN DE PROBLEMAS

## 📋 ÍNDICE
1. [Problemas de Imágenes Docker](#problemas-de-imágenes-docker)
2. [Problemas de Conectividad](#problemas-de-conectividad)
3. [Problemas de Base de Datos](#problemas-de-base-de-datos)
4. [Problemas de Ingress y Networking](#problemas-de-ingress-y-networking)
5. [Problemas de Recursos](#problemas-de-recursos)
6. [Problemas Específicos de Minikube](#problemas-específicos-de-minikube)
7. [Problemas Específicos de Azure AKS](#problemas-específicos-de-azure-aks)
8. [Comandos de Debugging](#comandos-de-debugging)

---

## 🐳 PROBLEMAS DE IMÁGENES DOCKER

### Problema 1: ImagePullBackOff en Minikube

**Síntomas:**
```bash
kubectl get pods -n microstore
NAME                                    READY   STATUS             RESTARTS   AGE
users-deployment-xxxx                   0/1     ImagePullBackOff   0          2m
```

**Causa:** La imagen no existe en el daemon de Docker de Minikube

**Solución:**
```bash
# 1. Configurar Docker para usar daemon de Minikube
eval $(minikube docker-env -p k8sLocal)

# 2. Verificar si la imagen existe
docker images | grep microstore

# 3. Si no existe, construirla nuevamente
docker build -t microstore-users:latest ./microUsers
docker build -t microstore-products:latest ./microProducts
docker build -t microstore-orders:latest ./microOrders
docker build -t microstore-frontend:latest ./frontend

# 4. Verificar que ahora existe
docker images | grep microstore

# 5. Eliminar el pod para que se recree
kubectl delete pod -l app=users -n microstore
```

**Prevención:**
- Siempre ejecutar `eval $(minikube docker-env -p k8sLocal)` antes de hacer `docker build`
- No cambiar entre terminales sin re-ejecutar el comando
- Verificar que `imagePullPolicy: Never` esté en los deployments

---

### Problema 2: ImagePullBackOff en Azure AKS

**Síntomas:**
```bash
kubectl get pods -n microstore
NAME                                    READY   STATUS             RESTARTS   AGE
users-deployment-xxxx                   0/1     ImagePullBackOff   0          2m
```

**Causa:** No se puede descargar la imagen desde ACR

**Solución 1: Verificar que la imagen existe en ACR**
```bash
# Obtener nombre del ACR
ACR_NAME=$(terraform -chdir=infra/terraform output -raw acr_name)

# Listar repositorios
az acr repository list --name $ACR_NAME --output table

# Listar tags de un repositorio
az acr repository show-tags --name $ACR_NAME --repository microstore-users
```

**Solución 2: Verificar conexión AKS-ACR**
```bash
# Verificar que AKS tiene acceso al ACR
az aks check-acr \
  --resource-group rg-microstore-dev \
  --name aks-microstore-cluster \
  --acr $ACR_NAME.azurecr.io

# Si falla, re-attach el ACR
az aks update \
  --name aks-microstore-cluster \
  --resource-group rg-microstore-dev \
  --attach-acr $ACR_NAME
```

**Solución 3: Verificar nombres de imagen en manifiestos**
```bash
# Las imágenes deben tener el formato:
# <ACR_LOGIN_SERVER>/microstore-<service>:latest

# Verificar en deployments
kubectl get deployment users-deployment -n microstore -o yaml | grep image:

# Debe mostrar algo como:
# image: myacr123.azurecr.io/microstore-users:latest
```

---

### Problema 3: Wrong Architecture (ARM vs AMD64)

**Síntomas:**
```bash
kubectl logs <pod-name> -n microstore
exec /usr/local/bin/python: exec format error
```

**Causa:** Imagen construida para arquitectura diferente (ej: M1 Mac = ARM, Cluster = AMD64)

**Solución:**
```bash
# Construir para plataforma específica
docker buildx build --platform linux/amd64 -t microstore-users:latest ./microUsers

# O en el script de build, agregar:
docker build --platform linux/amd64 -t <image-name> <directory>
```

---

## 🌐 PROBLEMAS DE CONECTIVIDAD

### Problema 4: Frontend No Conecta con APIs

**Síntomas:**
- Frontend carga pero muestra errores al intentar cargar usuarios/productos
- Console del navegador muestra errores CORS o 404

**Diagnóstico:**
```bash
# 1. Verificar ConfigMap
kubectl get configmap app-config -n microstore -o yaml

# Debe mostrar:
# EXTERNAL_IP: <IP-REAL>  # NO "CHANGE_ME"
```

**Solución para Minikube:**
```bash
# Actualizar con IP de Minikube
MINIKUBE_IP=$(minikube ip -p k8sLocal)
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$MINIKUBE_IP\"}}"

# Reiniciar frontend
kubectl rollout restart deployment/frontend-deployment -n microstore
```

**Solución para Azure AKS:**
```bash
# Actualizar con IP del Ingress
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl patch configmap app-config -n microstore \
  -p "{\"data\":{\"EXTERNAL_IP\":\"$INGRESS_IP\"}}"

# Reiniciar frontend
kubectl rollout restart deployment/frontend-deployment -n microstore
```

---

### Problema 5: Services No Responden

**Síntomas:**
```bash
curl http://<IP>/api/users/
# Connection refused o timeout
```

**Diagnóstico:**
```bash
# 1. Verificar que los pods están Running y Ready
kubectl get pods -n microstore

# 2. Verificar endpoints del servicio
kubectl get endpoints users-service -n microstore

# Debe mostrar IPs de los pods
# NAME            ENDPOINTS                         AGE
# users-service   10.244.0.5:5002,10.244.0.6:5002  5m
```

**Solución si no hay endpoints:**
```bash
# 1. Verificar labels del servicio y deployment
kubectl get svc users-service -n microstore -o yaml | grep selector -A 2
kubectl get pod -l app=users -n microstore

# Los labels deben coincidir

# 2. Verificar readinessProbe
kubectl describe pod <pod-name> -n microstore | grep -A 5 Readiness

# 3. Ver logs para errores
kubectl logs <pod-name> -n microstore
```

---

## 🗄️ PROBLEMAS DE BASE DE DATOS

### Problema 6: MySQL No Inicia

**Síntomas:**
```bash
kubectl get pods -n microstore
NAME          READY   STATUS    RESTARTS   AGE
mysql-0       0/1     Pending   0          5m
```

**Causa 1: PVC No Se Crea (StorageClass Incorrecto)**

**Diagnóstico:**
```bash
# Verificar PVC
kubectl get pvc -n microstore

# Verificar StorageClass disponibles
kubectl get storageclass
```

**Solución para Minikube:**
```bash
# Minikube usa 'standard' por defecto
# Si no existe, verificar addons
minikube addons list -p k8sLocal | grep storage

# Habilitar si es necesario
minikube addons enable storage-provisioner -p k8sLocal
minikube addons enable default-storageclass -p k8sLocal
```

**Solución para Azure AKS:**
```bash
# AKS debe tener storageclass por defecto
kubectl get storageclass

# Si no hay default, marcar una como default
kubectl patch storageclass managed-premium -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

**Causa 2: No Hay Recursos Suficientes**

**Diagnóstico:**
```bash
kubectl describe pod mysql-0 -n microstore
# Buscar eventos que digan "Insufficient CPU/Memory"

kubectl top nodes
```

**Solución:**
```bash
# En Minikube: Aumentar recursos
minikube stop -p k8sLocal
minikube delete -p k8sLocal
minikube start -p k8sLocal --cpus=4 --memory=6144

# En Azure: Escalar el node pool
az aks scale \
  --resource-group rg-microstore-dev \
  --name aks-microstore-cluster \
  --node-count 3
```

---

### Problema 7: MySQL Listo pero Microservicios No Conectan

**Síntomas:**
```bash
kubectl logs -f deployment/users-deployment -n microstore
Error: Can't connect to MySQL server on 'mysql-service'
```

**Diagnóstico:**
```bash
# 1. Verificar que MySQL está realmente listo
kubectl get pod mysql-0 -n microstore

# 2. Probar conexión desde otro pod
kubectl run mysql-client --rm -it --image=mysql:8.0 -n microstore -- \
  mysql -h mysql-service -u root -proot myflaskapp -e "SHOW TABLES;"
```

**Solución si falla la conexión:**
```bash
# 1. Verificar secret de base de datos
kubectl get secret database-secret -n microstore -o yaml

# Decodificar valores
kubectl get secret database-secret -n microstore -o jsonpath='{.data.DB_HOST}' | base64 -d
# Debe mostrar: mysql-service

kubectl get secret database-secret -n microstore -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
# Debe mostrar: root

# 2. Verificar servicio de MySQL
kubectl get svc mysql-service -n microstore
# Debe apuntar al puerto 3306

# 3. Ver logs de MySQL para errores
kubectl logs mysql-0 -n microstore --tail=100
```

---

## 🚪 PROBLEMAS DE INGRESS Y NETWORKING

### Problema 8: Ingress No Tiene IP Externa (Azure)

**Síntomas:**
```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx
NAME                       TYPE           EXTERNAL-IP   PORT(S)
ingress-nginx-controller   LoadBalancer   <pending>     80:30080/TCP,443:30443/TCP
```

**Solución:**
```bash
# 1. Esperar (puede tardar 2-5 minutos)
kubectl get svc ingress-nginx-controller -n ingress-nginx --watch

# 2. Si después de 5 minutos sigue pending, verificar eventos
kubectl describe svc ingress-nginx-controller -n ingress-nginx

# 3. Verificar cuota de IPs públicas en Azure
az network public-ip list -o table

# 4. Verificar que no hay errores en el LoadBalancer
az network lb list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o table
```

---

### Problema 9: 502 Bad Gateway en Ingress

**Síntomas:**
Al acceder a `http://<INGRESS-IP>/api/users/` se recibe error 502

**Diagnóstico:**
```bash
# 1. Verificar que los backends están running
kubectl get pods -n microstore

# 2. Verificar endpoints
kubectl get endpoints -n microstore

# 3. Ver configuración del Ingress
kubectl describe ingress -n microstore
```

**Solución:**
```bash
# 1. Verificar logs del Ingress Controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=50

# 2. Verificar que los paths en Ingress coinciden con las rutas de la app
kubectl get ingress -n microstore -o yaml

# 3. Probar directamente el servicio sin Ingress
kubectl port-forward svc/users-service 5002:80 -n microstore
curl http://localhost:5002/api/users/
```

---

## 💻 PROBLEMAS DE RECURSOS

### Problema 10: Pods en CrashLoopBackOff

**Síntomas:**
```bash
kubectl get pods -n microstore
NAME                                    READY   STATUS             RESTARTS   AGE
users-deployment-xxxx                   0/1     CrashLoopBackOff   5          5m
```

**Diagnóstico:**
```bash
# Ver logs del pod
kubectl logs <pod-name> -n microstore --tail=100

# Ver eventos
kubectl describe pod <pod-name> -n microstore
```

**Causas Comunes:**

**Causa 1: Error en el Código de la Aplicación**
```bash
# Ver logs para identificar el error
kubectl logs <pod-name> -n microstore

# Errores comunes:
# - ModuleNotFoundError: Falta dependencia en requirements.txt
# - Connection refused: No puede conectar a MySQL
# - Port already in use: Conflicto de puertos
```

**Causa 2: Variables de Entorno Incorrectas**
```bash
# Verificar variables de entorno del pod
kubectl exec <pod-name> -n microstore -- env | grep -E 'DB_|MYSQL_'

# Verificar que coinciden con los secrets
kubectl get secret database-secret -n microstore -o yaml
```

**Causa 3: Liveness/Readiness Probes Fallan**
```bash
# Ver configuración de probes
kubectl get deployment users-deployment -n microstore -o yaml | grep -A 10 Probe

# Probar manualmente
kubectl exec -it <pod-name> -n microstore -- curl http://localhost:5002/api/users/
```

---

## 🏠 PROBLEMAS ESPECÍFICOS DE MINIKUBE

### Problema 11: Minikube No Inicia

**Síntomas:**
```bash
minikube start -p k8sLocal
❌ Exiting due to GUEST_DRIVER_MISMATCH
```

**Solución:**
```bash
# 1. Eliminar cluster corrupto
minikube delete -p k8sLocal

# 2. Verificar driver disponible
minikube start -p k8sLocal --driver=docker
# O probar con otro driver
minikube start -p k8sLocal --driver=hyperv  # Windows
minikube start -p k8sLocal --driver=virtualbox

# 3. Si persiste, reinstalar Minikube
# Windows (PowerShell como Admin):
choco install minikube

# Linux:
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

---

### Problema 12: No Puedo Acceder a la Aplicación en Minikube

**Solución 1: Usar minikube service**
```bash
minikube service frontend-service -n microstore -p k8sLocal
# Esto abrirá automáticamente el navegador con la URL correcta
```

**Solución 2: Usar minikube tunnel**
```bash
# En terminal separada (requiere sudo):
minikube tunnel -p k8sLocal

# Luego acceder a:
kubectl get svc frontend-service -n microstore
# Usar la EXTERNAL-IP mostrada
```

**Solución 3: Port Forwarding**
```bash
kubectl port-forward svc/frontend-service 8080:80 -n microstore
# Acceder a: http://localhost:8080
```

---

## ☁️ PROBLEMAS ESPECÍFICOS DE AZURE AKS

### Problema 13: No Puedo Hacer az aks get-credentials

**Síntomas:**
```bash
az aks get-credentials --resource-group rg-microstore-dev --name aks-microstore-cluster
ERROR: The client '<email>' with object id '<id>' does not have authorization
```

**Solución:**
```bash
# 1. Verificar que estás autenticado
az account show

# 2. Verificar permisos
az role assignment list --assignee <tu-email> --output table

# 3. Si no tienes permisos, pedir al admin que te asigne rol
# El admin debe ejecutar:
az role assignment create \
  --role "Azure Kubernetes Service Cluster User Role" \
  --assignee <tu-email> \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-microstore-dev/providers/Microsoft.ContainerService/managedClusters/aks-microstore-cluster
```

---

### Problema 14: Cluster AKS Está Stopped

**Síntomas:**
```bash
kubectl get nodes
Unable to connect to the server: EOF
```

**Solución:**
```bash
# Verificar estado del cluster
az aks show \
  --resource-group rg-microstore-dev \
  --name aks-microstore-cluster \
  --query "powerState"

# Si está Stopped, iniciarlo
az aks start \
  --resource-group rg-microstore-dev \
  --name aks-microstore-cluster

# Esperar a que esté Running (puede tardar 5-10 minutos)
```

---

## 🔍 COMANDOS DE DEBUGGING UNIVERSALES

### Verificar Estado General
```bash
# Ver todos los recursos
kubectl get all -n microstore

# Ver solo pods con más detalles
kubectl get pods -n microstore -o wide

# Ver eventos recientes
kubectl get events -n microstore --sort-by='.lastTimestamp' | tail -20
```

### Logs y Debugging
```bash
# Logs de un deployment
kubectl logs -f deployment/users-deployment -n microstore

# Logs de un pod específico
kubectl logs <pod-name> -n microstore --tail=100

# Logs anteriores (si el pod se reinició)
kubectl logs <pod-name> -n microstore --previous

# Entrar a un pod
kubectl exec -it <pod-name> -n microstore -- /bin/bash

# Ejecutar comando en un pod
kubectl exec <pod-name> -n microstore -- curl http://localhost:5002/api/users/
```

### Información Detallada
```bash
# Describir un recurso (muestra eventos y configuración)
kubectl describe pod <pod-name> -n microstore
kubectl describe svc <service-name> -n microstore
kubectl describe deployment <deployment-name> -n microstore

# Ver definición YAML completa
kubectl get pod <pod-name> -n microstore -o yaml
kubectl get svc <service-name> -n microstore -o yaml
```

### Verificar Configuración
```bash
# Ver secrets (decodificados)
kubectl get secret database-secret -n microstore -o jsonpath='{.data.DB_PASSWORD}' | base64 -d

# Ver configmap
kubectl get configmap app-config -n microstore -o yaml

# Ver variables de entorno de un pod
kubectl exec <pod-name> -n microstore -- env
```

### Recursos y Performance
```bash
# Ver uso de recursos de nodos
kubectl top nodes

# Ver uso de recursos de pods
kubectl top pods -n microstore

# Ver requests y limits configurados
kubectl describe pod <pod-name> -n microstore | grep -A 5 "Limits\|Requests"
```

### Networking
```bash
# Ver todos los servicios
kubectl get svc -n microstore

# Ver endpoints de un servicio
kubectl get endpoints <service-name> -n microstore

# Probar conectividad entre pods
kubectl run test-pod --rm -it --image=busybox -n microstore -- sh
# Dentro del pod:
wget -qO- http://users-service/api/users/
```

### Reiniciar y Actualizar
```bash
# Reiniciar un deployment
kubectl rollout restart deployment/users-deployment -n microstore

# Ver estado del rollout
kubectl rollout status deployment/users-deployment -n microstore

# Ver historial de rollouts
kubectl rollout history deployment/users-deployment -n microstore

# Rollback a versión anterior
kubectl rollout undo deployment/users-deployment -n microstore
```

---

## 📞 CUANDO TODO LO DEMÁS FALLA

### Estrategia de Debugging Paso a Paso

1. **Verificar contexto correcto:**
   ```bash
   kubectl config current-context
   kubectl config use-context <correcto>
   ```

2. **Verificar namespace:**
   ```bash
   kubectl get namespace microstore
   ```

3. **Ver estado de TODOS los pods:**
   ```bash
   kubectl get pods --all-namespaces
   ```

4. **Verificar orden de dependencias:**
   - MySQL debe estar Ready antes que los microservicios
   - Los microservicios deben estar Ready antes que el frontend

5. **Eliminar y recrear recursos problema:**
   ```bash
   kubectl delete pod <pod-name> -n microstore
   # O todo el deployment:
   kubectl delete deployment <deployment-name> -n microstore
   kubectl apply -f k8s/<service>/deployment.yaml
   ```

6. **Eliminar TODO y empezar de cero:**
   ```bash
   kubectl delete namespace microstore
   # Esperar a que se elimine completamente
   kubectl get namespace microstore
   # Cuando ya no aparezca, volver a desplegar
   ./scripts/deploy-minikube.sh  # o deploy-aks.sh
   ```

---

## 🆘 OBTENER AYUDA

Si después de todo no puedes resolver el problema:

1. **Recopilar información:**
   ```bash
   # Crear reporte de debugging
   kubectl get all -n microstore > debug-report.txt
   kubectl describe pods -n microstore >> debug-report.txt
   kubectl logs -l app=users -n microstore --tail=50 >> debug-report.txt
   kubectl get events -n microstore --sort-by='.lastTimestamp' >> debug-report.txt
   ```

2. **Buscar en logs:**
   - Buscar palabras clave: "Error", "Failed", "Warning", "refused"

3. **Consultar documentación oficial:**
   - [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/)
   - [Minikube Issues](https://github.com/kubernetes/minikube/issues)
   - [Azure AKS Troubleshooting](https://docs.microsoft.com/en-us/azure/aks/troubleshooting)
