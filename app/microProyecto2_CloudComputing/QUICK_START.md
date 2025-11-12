# 🚀 INICIO RÁPIDO - MICROSTORE

## ⚡ Despliegue en 3 Pasos

### Paso 1: Clonar y Entrar al Proyecto
```bash
cd microProyecto2_CloudComputing
```

### Paso 2: Ejecutar Quickstart
```bash
chmod +x quickstart.sh
./quickstart.sh
```

### Paso 3: Seleccionar Entorno
El script detectará automáticamente los entornos disponibles:
- **Minikube** (local) - Si tienes Minikube y Docker
- **Azure AKS** (nube) - Si tienes Azure CLI configurado

---

## 📚 DOCUMENTACIÓN COMPLETA

| Documento | Descripción |
|-----------|-------------|
| **[GUIA_DESPLIEGUE_COMPLETA.md](GUIA_DESPLIEGUE_COMPLETA.md)** | 📖 Guía detallada paso a paso para Minikube y Azure AKS |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | 🔧 Solución a 14+ problemas comunes |
| **[CORRECCIONES.md](CORRECCIONES.md)** | 📋 Resumen de correcciones y mejoras implementadas |
| **[README.md](README.md)** | 📘 Documentación original del proyecto |

---

## 🎯 SCRIPTS DISPONIBLES

### Despliegue Rápido
```bash
./quickstart.sh                    # Asistente interactivo
./scripts/deploy-unified.sh        # Menú completo de opciones
```

### Despliegue Específico
```bash
./scripts/deploy-minikube.sh       # Desplegar en Minikube (local)
./scripts/deploy-aks.sh            # Desplegar en Azure AKS
```

### Construcción de Imágenes
```bash
./scripts/build-images.sh          # Linux/Mac
./scripts/build-images.ps1         # Windows PowerShell
```

---

## 🏠 MINIKUBE (LOCAL)

### Prerequisitos
- Docker
- Minikube
- kubectl

### Despliegue
```bash
# Opción 1: Quickstart
./quickstart.sh

# Opción 2: Script directo
./scripts/deploy-minikube.sh

# Opción 3: Kustomize
kubectl apply -k k8s/overlays/minikube
```

### Acceso
```bash
# Abrir aplicación automáticamente
minikube service frontend-service -n microstore -p k8sLocal

# O ver IP y puerto
MINIKUBE_IP=$(minikube ip -p k8sLocal)
NODEPORT=$(kubectl get svc frontend-service -n microstore -o jsonpath='{.spec.ports[0].nodePort}')
echo "Frontend: http://$MINIKUBE_IP:$NODEPORT"
```

---

## ☁️ AZURE AKS

### Prerequisitos
- Azure CLI (`az`)
- Terraform (para infraestructura)
- Docker
- kubectl

### Despliegue
```bash
# Opción 1: Quickstart
./quickstart.sh

# Opción 2: Script directo (incluye infraestructura)
./scripts/deploy-aks.sh

# Opción 3: Manual
cd infra/terraform && terraform apply && cd ../..
./scripts/build-images.sh
kubectl apply -k k8s/overlays/azure
```

### Acceso
```bash
# Obtener IP pública
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Frontend: http://$INGRESS_IP/"
```

---

## 🔍 VERIFICACIÓN

```bash
# Ver estado de pods
kubectl get pods -n microstore

# Ver servicios
kubectl get svc -n microstore

# Ver Ingress
kubectl get ingress -n microstore

# Probar API
curl http://<IP>/api/users/ | jq .
```

---

## 🧹 LIMPIEZA

### Solo Aplicación (Mantener Cluster)
```bash
kubectl delete namespace microstore
```

### Cluster Completo

**Minikube:**
```bash
minikube delete -p k8sLocal
```

**Azure AKS:**
```bash
# Detener (ahorra costos)
az aks stop --resource-group rg-microstore-dev --name aks-microstore-cluster

# Destruir todo
cd infra/terraform && terraform destroy
```

---

## 🆘 AYUDA

### Problemas Comunes
Consulta **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** para soluciones detalladas

### Comandos de Debugging
```bash
kubectl logs -f deployment/users-deployment -n microstore
kubectl describe pod <pod-name> -n microstore
kubectl get events -n microstore --sort-by='.lastTimestamp'
```

---

## 📊 ARQUITECTURA

```
🌐 Internet
    ↓
🚪 Ingress Controller
    ↓
☸️  Kubernetes Cluster
    ├── 🌐 Frontend (Flask + Bootstrap)
    ├── 👥 Users Microservice (Flask + MySQL)
    ├── 📦 Products Microservice (Flask + MySQL)
    ├── 📋 Orders Microservice (Flask + MySQL)
    └── 🗄️ MySQL 8.0 StatefulSet
        └── 💾 Persistent Volume (Azure Disk / Minikube hostPath)
```

---

## 🎓 CREDENCIALES DE PRUEBA

- **Usuario:** `lucia`
- **Password:** `pass1`

O ver más usuarios en `init.sql`

---

## 📞 SOPORTE

1. ✅ Lee [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. ✅ Consulta [GUIA_DESPLIEGUE_COMPLETA.md](GUIA_DESPLIEGUE_COMPLETA.md)
3. ✅ Revisa logs: `kubectl logs <pod-name> -n microstore`

---

**Proyecto:** Computación en la Nube  
**Entornos:** Minikube, Azure AKS, AWS EKS (futuro)  
**Gestión:** Rancher (ver INFRASTRUCTURE.md)
