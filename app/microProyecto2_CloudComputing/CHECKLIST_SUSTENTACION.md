# ✅ CHECKLIST DE PREPARACIÓN PARA SUSTENTACIÓN

## 📋 ANTES DE LA SUSTENTACIÓN

### 1. Verificación de Entornos

#### Minikube (Local)
- [ ] Minikube está instalado y funcional
  ```bash
  minikube version
  ```
- [ ] Docker Desktop está corriendo
  ```bash
  docker ps
  ```
- [ ] kubectl está instalado
  ```bash
  kubectl version --client
  ```
- [ ] Despliegue funciona correctamente
  ```bash
  ./scripts/deploy-minikube.sh
  ```
- [ ] Aplicación es accesible
  ```bash
  minikube service frontend-service -n microstore -p k8sLocal
  ```

#### Azure AKS
- [ ] Sesión de Azure activa
  ```bash
  az account show
  ```
- [ ] Infraestructura desplegada con Terraform
  ```bash
  cd infra/terraform && terraform output
  ```
- [ ] Cluster AKS está corriendo
  ```bash
  az aks show --resource-group rg-microstore-dev --name aks-microstore-cluster --query powerState
  ```
- [ ] kubectl configurado para AKS
  ```bash
  kubectl config current-context
  kubectl get nodes
  ```
- [ ] Aplicación es accesible
  ```bash
  kubectl get svc ingress-nginx-controller -n ingress-nginx
  ```

#### Rancher (Gestión Centralizada)
- [ ] Rancher está accesible
  ```
  https://<RANCHER-IP>
  Usuario: admin
  Password: proyectoCCG1 (o la que hayas definido)
  ```
- [ ] Cluster Minikube registrado en Rancher
- [ ] Cluster AKS registrado en Rancher
- [ ] Cluster EKS registrado en Rancher (opcional)
- [ ] Todos los clusters muestran estado "Active"

### 2. Verificación de la Aplicación

#### Frontend
- [ ] Página principal carga correctamente
- [ ] Login funciona con credenciales de prueba (`lucia` / `pass1`)
- [ ] Dashboard es visible después del login
- [ ] Navegación entre secciones funciona

#### APIs de Microservicios
- [ ] **Users API** responde
  ```bash
  curl http://<IP>/api/users/ | jq .
  ```
- [ ] **Products API** responde
  ```bash
  curl http://<IP>/api/products/ | jq .
  ```
- [ ] **Orders API** responde
  ```bash
  curl http://<IP>/api/orders/ | jq .
  ```

#### Base de Datos
- [ ] MySQL está corriendo y listo
  ```bash
  kubectl get pod mysql-0 -n microstore
  ```
- [ ] Datos de prueba están cargados
  ```bash
  kubectl exec -it mysql-0 -n microstore -- mysql -u root -proot myflaskapp -e "SELECT COUNT(*) FROM users;"
  ```

### 3. Documentación Lista

- [ ] **QUICK_START.md** - Inicio rápido revisado
- [ ] **GUIA_DESPLIEGUE_COMPLETA.md** - Guía detallada revisada
- [ ] **TROUBLESHOOTING.md** - Solución de problemas revisada
- [ ] **CORRECCIONES.md** - Resumen de mejoras revisado
- [ ] **README.md** - Documentación original actualizada
- [ ] **INFRASTRUCTURE.md** - Infraestructura con Rancher documentada

### 4. Scripts Funcionales

- [ ] `quickstart.sh` - Ejecuta sin errores
- [ ] `scripts/deploy-minikube.sh` - Ejecuta sin errores
- [ ] `scripts/deploy-aks.sh` - Ejecuta sin errores
- [ ] `scripts/deploy-unified.sh` - Menú funciona correctamente
- [ ] `scripts/build-images.sh` - Construye imágenes correctamente
- [ ] Todos los scripts tienen permisos de ejecución
  ```bash
  chmod +x *.sh scripts/*.sh
  ```

---

## 🎯 DURANTE LA SUSTENTACIÓN

### Demo Recomendada (20-30 minutos)

#### 1. Introducción (5 min)
- [ ] Presentar arquitectura general
- [ ] Explicar entornos: Minikube, Azure AKS, (AWS EKS opcional)
- [ ] Mostrar Rancher como punto central de gestión

#### 2. Infraestructura con Rancher (5 min)
- [ ] Mostrar Rancher Dashboard
- [ ] Mostrar clusters registrados (k8sLocal, k8s-azure, rancher-eks-cluster)
- [ ] Mostrar estado de nodos en cada cluster
- [ ] Explicar rol de Rancher en la gestión multinube

#### 3. Despliegue en Minikube (5 min)
- [ ] Ejecutar `./scripts/deploy-minikube.sh`
- [ ] Explicar proceso mientras se ejecuta:
  - Verificación de prerequisitos
  - Construcción de imágenes locales
  - Aplicación de manifiestos
  - Configuración automática
- [ ] Mostrar aplicación funcionando
- [ ] Demostrar acceso a través de `minikube service`

#### 4. Despliegue en Azure AKS (5 min)
- [ ] Mostrar infraestructura en Azure Portal
- [ ] Ejecutar `./scripts/deploy-aks.sh` (o mostrar ya desplegado)
- [ ] Explicar integración con ACR
- [ ] Mostrar aplicación con IP pública
- [ ] Demostrar escalabilidad (opcional)

#### 5. Funcionalidad de la Aplicación (5 min)
- [ ] Hacer login con usuario de prueba
- [ ] Navegar por secciones (Users, Products, Orders)
- [ ] Crear/editar un usuario
- [ ] Crear/editar un producto
- [ ] Crear una orden
- [ ] Mostrar que los cambios persisten (MySQL)

#### 6. Troubleshooting y Gestión (5 min)
- [ ] Mostrar comandos de debugging
  ```bash
  kubectl get pods -n microstore
  kubectl logs <pod-name> -n microstore
  kubectl describe pod <pod-name> -n microstore
  ```
- [ ] Demostrar reinicio de un servicio
  ```bash
  kubectl rollout restart deployment/users-deployment -n microstore
  ```
- [ ] Mostrar monitoreo en Rancher
- [ ] (Opcional) Mostrar Container Insights en Azure

---

## 📊 PREGUNTAS FRECUENTES - PREPARACIÓN

### ¿Por qué usar Kubernetes?
**Respuesta:**
- ✅ Orquestación automática de contenedores
- ✅ Alta disponibilidad y auto-recuperación
- ✅ Escalabilidad horizontal automática
- ✅ Portabilidad entre nubes (Azure, AWS, local)
- ✅ Gestión declarativa con YAML

### ¿Por qué Rancher?
**Respuesta:**
- ✅ Gestión centralizada de múltiples clusters
- ✅ Panel unificado para monitoreo
- ✅ Facilita el registro de clusters en diferentes nubes
- ✅ Balanceo de carga entre clusters
- ✅ Control de acceso y seguridad centralizado

### ¿Qué diferencia hay entre Minikube y AKS?
**Respuesta:**

| Aspecto | Minikube | Azure AKS |
|---------|----------|-----------|
| **Entorno** | Local, un solo nodo | Nube, múltiples nodos |
| **Escalabilidad** | Limitada | Auto-scaling |
| **Costo** | Gratis | Consume créditos Azure |
| **Uso** | Desarrollo y pruebas | Producción |
| **LoadBalancer** | Requiere tunnel | IP pública automática |

### ¿Cómo funciona el despliegue multinube?
**Respuesta:**
1. Cada cluster (Minikube, AKS, EKS) se crea independientemente
2. Todos los clusters se registran en Rancher
3. Rancher permite desplegar la misma aplicación en todos
4. Se configura balanceo de carga entre clusters
5. Monitoreo centralizado desde Rancher

### ¿Qué pasa si un cluster falla?
**Respuesta:**
- ✅ Los otros clusters siguen funcionando
- ✅ Rancher detecta el cluster caído
- ✅ Tráfico se redirige automáticamente a clusters sanos
- ✅ Los datos persisten en MySQL de cada cluster
- ✅ Se puede restaurar el cluster o agregar uno nuevo

### ¿Cómo se gestionan los secretos?
**Respuesta:**
- Kubernetes Secrets para información sensible (passwords, tokens)
- Codificados en base64
- Inyectados como variables de entorno en los pods
- No se comitean al repositorio (solo plantillas)

### ¿Cómo se hace el CI/CD?
**Respuesta (para futuro):**
- GitHub Actions o Azure DevOps para CI
- Build automático de imágenes en cada commit
- Push automático a ACR
- Deploy automático a clusters via kubectl o Rancher
- Rollback automático si fallan health checks

---

## 🚨 PROBLEMAS COMUNES Y SOLUCIONES RÁPIDAS

### "ImagePullBackOff"
```bash
# Minikube:
eval $(minikube docker-env -p k8sLocal)
docker build -t microstore-users:latest ./microUsers

# Azure:
az acr login --name <ACR_NAME>
docker push <ACR_LOGIN_SERVER>/microstore-users:latest
```

### "MySQL no inicia"
```bash
kubectl describe pod mysql-0 -n microstore
kubectl logs mysql-0 -n microstore
# Verificar PVC
kubectl get pvc -n microstore
```

### "No puedo acceder a la aplicación"
```bash
# Minikube:
minikube service frontend-service -n microstore -p k8sLocal

# Azure:
kubectl get svc ingress-nginx-controller -n ingress-nginx
# Esperar a que aparezca EXTERNAL-IP
```

### "Rancher no muestra el cluster"
```bash
# Verificar agentes de Rancher
kubectl get pods -n cattle-system
# Si no están, re-importar cluster desde Rancher UI
```

---

## 📸 CAPTURAS RECOMENDADAS

Tener listas capturas de pantalla de:

1. **Rancher Dashboard** mostrando los 3 clusters
2. **Azure Portal** con recursos del AKS
3. **Aplicación funcionando** (frontend con datos)
4. **Kubectl get all** mostrando todos los recursos
5. **Monitoreo** en Rancher o Azure Monitor
6. **Arquitectura** (diagrama del README)

---

## 💾 BACKUP ANTES DE LA SUSTENTACIÓN

### Exportar Configuraciones
```bash
# Exportar todos los manifiestos aplicados
mkdir backup-sustentacion
kubectl get all -n microstore -o yaml > backup-sustentacion/all-resources.yaml
kubectl get configmap -n microstore -o yaml > backup-sustentacion/configmaps.yaml
kubectl get secret -n microstore -o yaml > backup-sustentacion/secrets.yaml
kubectl get pvc -n microstore -o yaml > backup-sustentacion/pvcs.yaml
```

### Backup de Datos de MySQL
```bash
kubectl exec mysql-0 -n microstore -- mysqldump -u root -proot myflaskapp > backup-sustentacion/mysql-backup.sql
```

---

## ⏰ TIMELINE SUGERIDA

### 2 Días Antes
- [ ] Verificar que todos los prerequisitos están instalados
- [ ] Probar despliegue completo en Minikube
- [ ] Probar despliegue completo en Azure AKS
- [ ] Registrar clusters en Rancher
- [ ] Tomar capturas de pantalla

### 1 Día Antes
- [ ] Hacer un dry-run de la presentación
- [ ] Cronometrar cada sección
- [ ] Preparar respuestas a preguntas frecuentes
- [ ] Revisar toda la documentación

### Día de la Sustentación - Mañana
- [ ] Verificar que Azure AKS está corriendo (no stopped)
- [ ] Verificar que Rancher es accesible
- [ ] Hacer un despliegue de prueba completo
- [ ] Verificar conectividad a internet
- [ ] Cargar créditos en Azure si es necesario

### 1 Hora Antes
- [ ] Desplegar aplicación en todos los entornos
- [ ] Verificar que todo funciona
- [ ] Tener URLs listas para demostrar
- [ ] Tener terminal y navegador abiertos
- [ ] Revisar checklist una última vez

---

## 🎉 DESPUÉS DE LA SUSTENTACIÓN

### Limpieza de Recursos (Ahorrar Costos)
```bash
# Detener AKS (no eliminar)
az aks stop --resource-group rg-microstore-dev --name aks-microstore-cluster

# O eliminar todo si ya no es necesario
cd infra/terraform && terraform destroy
```

### Documentar Feedback
- [ ] Anotar preguntas que no esperabas
- [ ] Anotar sugerencias de mejora
- [ ] Actualizar documentación si es necesario

---

## 📞 CONTACTOS DE EMERGENCIA

- **Azure Support**: https://portal.azure.com (si hay problemas con la cuenta)
- **Rancher Docs**: https://rancher.com/docs/
- **Kubernetes Docs**: https://kubernetes.io/docs/

---

**¡Buena suerte en tu sustentación! 🚀**

Recuerda:
- ✅ Mantén la calma
- ✅ Explica con claridad
- ✅ Si algo falla, tienes troubleshooting preparado
- ✅ Conoces tu proyecto mejor que nadie
