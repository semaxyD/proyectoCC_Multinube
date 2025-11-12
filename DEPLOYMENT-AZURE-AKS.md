# Guía de Implementación - Azure AKS

## 📋 Información del Cluster

- **Cluster:** k8s-azure
- **Resource Group:** rg-k8s-azure
- **Región:** eastus2
- **ACR:** acrk8sazure1762621825.azurecr.io
- **IP Pública:** 20.15.66.143

---

## 📥 Paso 1: Clonar Repositorio

```bash
cd ~
git clone https://github.com/Makhai412/proyectoFinalCloudComputing.git
cd proyectoFinalCloudComputing/microProyecto2_CloudComputing
```

---

## ✅ Paso 2: Configurar Secret de Base de Datos

```bash
kubectl create secret generic database-secret -n microstore \
  --from-literal=MYSQL_HOST=mysql-service \
  --from-literal=MYSQL_USER=root \
  --from-literal=MYSQL_PASSWORD=root \
  --from-literal=MYSQL_DB=microstore \
  --from-literal=MYSQL_PORT=3306

kubectl rollout restart deployment users-deployment -n microstore
kubectl rollout restart deployment products-deployment -n microstore
kubectl rollout restart deployment orders-deployment -n microstore
kubectl rollout restart deployment frontend-deployment -n microstore
```

---

## 🌐 Paso 3: Configurar Ingress Controller

```bash
# Instalar NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Esperar a que esté listo
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Configurar ingressClassName
kubectl patch ingress frontend-ingress -n microstore --type='json' \
  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'
kubectl patch ingress users-ingress -n microstore --type='json' \
  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'
kubectl patch ingress products-ingress -n microstore --type='json' \
  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'
kubectl patch ingress orders-ingress -n microstore --type='json' \
  -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'
```

---

## 🔗 Paso 4: Configurar Comunicación Entre Microservicios

**Modificar:** `microOrders/orders/controllers/order_controller.py`

```python
import os
PRODUCTS_SERVICE_URL = os.getenv('PRODUCTS_SERVICE_URL', 'http://localhost:5003')
resp = requests.get(f'{PRODUCTS_SERVICE_URL}/api/products/{product_id}')
```

**Modificar:** `k8s/orders/deployment.yaml`

```yaml
env:
  - name: PRODUCTS_SERVICE_URL
    value: "http://products-service"
```

**Redesplegar:**

```bash
az acr build --registry acrk8sazure1762621825 \
  --image microstore-orders:latest \
  --file microOrders/Dockerfile ./microOrders

kubectl apply -f k8s/orders/deployment.yaml
kubectl rollout restart deployment orders-deployment -n microstore
```

---

## 🎯 Paso 5: Integración con Rancher

En Rancher UI (`https://52.225.216.248`):
1. **☰ → Cluster Management → Import Existing**
2. Nombre: `k8s-azure`
3. Copiar comando

```bash
kubectl apply -f https://52.225.216.248/v3/import/xxxxxxxxxxxxxx.yaml
kubectl wait --for=condition=ready pod -n cattle-system --all --timeout=5m
```

---

## 🔄 Paso 6: Script de Reinicio

**Archivo:** `scripts/restart-aks.sh`

```bash
#!/bin/bash
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
kubectl rollout restart deployment users-deployment -n microstore
kubectl rollout restart deployment products-deployment -n microstore
kubectl rollout restart deployment orders-deployment -n microstore
kubectl rollout restart deployment frontend-deployment -n microstore

kubectl wait --for=condition=ready pod -l app=users -n microstore --timeout=5m
kubectl wait --for=condition=ready pod -l app=products -n microstore --timeout=5m
kubectl wait --for=condition=ready pod -l app=orders -n microstore --timeout=5m
kubectl wait --for=condition=ready pod -l app=frontend -n microstore --timeout=5m

echo "✅ Aplicación lista en: http://20.15.66.143/"
```

**Uso:**

```bash
chmod +x scripts/restart-aks.sh
./scripts/restart-aks.sh
```

---

## ✅ Verificación

```bash
# Ver estado
kubectl get pods -n microstore
kubectl get ingress -n microstore

# Probar endpoints
curl http://20.15.66.143/users/
curl http://20.15.66.143/products/
```

**Acceso:**
- Frontend: http://20.15.66.143/
- API Users: http://20.15.66.143/users/
- API Products: http://20.15.66.143/products/
- API Orders: http://20.15.66.143/orders/

---

## 🔄 Reiniciar Cluster Detenido

```bash
az aks start --name k8s-azure --resource-group rg-k8s-azure
az aks get-credentials --resource-group rg-k8s-azure --name k8s-azure --overwrite-existing
./scripts/restart-aks.sh
```

---

## 📝 Comandos Útiles

```bash
# Monitoreo
kubectl get all -n microstore
kubectl logs -n microstore -l app=users -f --tail=50

# Actualizar imagen
az acr build --registry acrk8sazure1762621825 --image microstore-users:latest ./microUsers
kubectl rollout restart deployment users-deployment -n microstore

# Escalar deployment
kubectl scale deployment users-deployment -n microstore --replicas=3
```

---

**Estado:** ✅ Implementación Exitosa  
**URL:** http://20.15.66.143/  
**Fecha:** Noviembre 11, 2025
