# Guía de Despliegue - Ambiente Local con Minikube

## 📋 Requisitos Previos

### Software Necesario
- **VirtualBox** 6.1 o superior
- **Vagrant** 2.2 o superior
- **Git** para clonar el repositorio
- **Navegador web** para acceder a la aplicación y Rancher

### Recursos del Sistema
- **RAM**: Mínimo 8GB (se asignarán 4GB a la VM)
- **CPU**: Mínimo 4 cores
- **Disco**: 20GB libres

---

## 🚀 Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/semaxyD/proyectoCC_Multinube.git
cd proyectoCC_Multinube/app
```

---

## 🖥️ Paso 2: Levantar la Máquina Virtual con Vagrant

### 2.1 Iniciar la VM

```bash
cd microProyecto2_CloudComputing
vagrant up
```

Este comando:
- Crea una VM Ubuntu 22.04 con 4GB RAM y 4 CPUs
- Instala Docker y Minikube automáticamente
- Configura la red con IP estática: `192.168.56.10`
- Tarda aproximadamente **10-15 minutos** en completarse

### 2.2 Conectarse a la VM

```bash
vagrant ssh
```

---

## ☸️ Paso 3: Iniciar Minikube

Dentro de la VM, ejecuta:

```bash
# Iniciar Minikube con 3GB de memoria
minikube start --driver=docker --memory=3000 --cpus=2

# Verificar el estado
minikube status

# Habilitar métricas (opcional)
minikube addons enable metrics-server
```

**Salida esperada:**
```
✅ minikube v1.34.0 on Ubuntu 22.04
✅ Using the docker driver based on user configuration
✅ Starting "minikube" primary control-plane node in "minikube" cluster
✅ Done! kubectl is now configured to use "minikube" cluster
```

---

## 🗄️ Paso 4: Desplegar MySQL

### 4.1 Crear Namespace

```bash
kubectl create namespace microstore
```

### 4.2 Aplicar Configuraciones de MySQL

```bash
# Secret para credenciales
kubectl apply -f k8s/common/database-secret.yaml

# ConfigMap para inicialización
kubectl apply -f k8s/mysql/mysql-initdb-configmap.yaml

# Secret específico de MySQL
kubectl apply -f k8s/mysql/secret.yaml

# Servicios
kubectl apply -f k8s/mysql/headless-service.yaml
kubectl apply -f k8s/mysql/service.yaml

# StatefulSet
kubectl apply -f k8s/mysql/statefulset.yaml
```

### 4.3 Verificar MySQL

```bash
# Ver el pod de MySQL
kubectl get pods -n microstore

# Debe mostrar:
# NAME      READY   STATUS    RESTARTS   AGE
# mysql-0   1/1     Running   0          2m

# Ver logs
kubectl logs -n microstore mysql-0 --tail=20
```

### 4.4 Poblar la Base de Datos (Opcional)

```bash
# Conectarse a MySQL
kubectl exec -it mysql-0 -n microstore -- mysql -u root microstore

# Insertar datos de prueba
INSERT INTO users (name, email, username, password) 
VALUES ('Admin', 'admin@test.com', 'admin', '$2b$12$abcdefghijklmnopqrstuvwxyz');

INSERT INTO products (name, description, price, stock) 
VALUES ('Laptop', 'Dell XPS 15', 1500.00, 10);

INSERT INTO products (name, description, price, stock) 
VALUES ('Mouse', 'Logitech MX Master', 99.99, 50);

-- Salir
EXIT;
```

---

## 🔧 Paso 5: Desplegar Microservicios

### 5.1 ConfigMap Común

```bash
kubectl apply -f k8s/common/configmap.yaml
```

### 5.2 Microservicio de Usuarios

```bash
kubectl apply -f k8s/users/deployment.yaml
kubectl apply -f k8s/users/service.yaml
kubectl apply -f k8s/users/ingress.yaml

# Verificar
kubectl get pods -n microstore -l app=users
```

### 5.3 Microservicio de Productos

```bash
kubectl apply -f k8s/products/deployment.yaml
kubectl apply -f k8s/products/service.yaml
kubectl apply -f k8s/products/ingress.yaml

# Verificar
kubectl get pods -n microstore -l app=products
```

### 5.4 Microservicio de Órdenes

```bash
kubectl apply -f k8s/orders/deployment.yaml
kubectl apply -f k8s/orders/service.yaml
kubectl apply -f k8s/orders/ingress.yaml

# Verificar
kubectl get pods -n microstore -l app=orders
```

### 5.5 Frontend

```bash
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml
kubectl apply -f k8s/frontend/ingress.yaml

# Verificar
kubectl get pods -n microstore -l app=frontend
```

---

## 🌐 Paso 6: Configurar Ingress Controller

### 6.1 Habilitar Ingress en Minikube

```bash
minikube addons enable ingress

# Verificar que el controlador esté corriendo
kubectl get pods -n ingress-nginx
```

### 6.2 Obtener IP de Minikube

```bash
minikube ip
# Salida esperada: 192.168.49.2 (o similar)
```
## ✅ Paso 7: Verificar el Despliegue

### 7.1 Ver todos los recursos

```bash
kubectl get all -n microstore
```

**Salida esperada:**
```
NAME                                     READY   STATUS    RESTARTS   AGE
pod/frontend-deployment-xxxxx-xxxxx      1/1     Running   0          5m
pod/mysql-0                              1/1     Running   0          10m
pod/orders-deployment-xxxxx-xxxxx        1/1     Running   0          5m
pod/products-deployment-xxxxx-xxxxx      1/1     Running   0          5m
pod/users-deployment-xxxxx-xxxxx         1/1     Running   0          5m

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/frontend-service     ClusterIP   10.96.xxx.xxx    <none>        80/TCP     5m
service/mysql-headless       ClusterIP   None             <none>        3306/TCP   10m
service/mysql-service        ClusterIP   10.96.xxx.xxx    <none>        3306/TCP   10m
service/orders-service       ClusterIP   10.96.xxx.xxx    <none>        80/TCP     5m
service/products-service     ClusterIP   10.96.xxx.xxx    <none>        80/TCP     5m
service/users-service        ClusterIP   10.96.xxx.xxx    <none>        80/TCP     5m
```

### 7.2 Probar los endpoints

```bash
# Probar usuarios
curl http://192.168.56.10/api/users/

# Probar productos
curl http://192.168.56.10/api/products/

# Probar órdenes
curl http://192.168.56.10/api/orders/
```

### 7.3 Acceder a la aplicación

Abre tu navegador y visita:
```
http://192.168.56.10/
```

**Credenciales de prueba:**
- Usuario: `admin`
- Contraseña: (la que insertaste en la BD)

---

## 🎯 Paso 8: Integración con Rancher

### 8.1 Requisitos
- Rancher Server ya desplegado (ejemplo: en Azure VM)
- URL de Rancher: `https://52.225.216.248`

### 8.2 Conectar Minikube a Rancher

1. **En Rancher UI:**
   - Ir a **Cluster Management**
   - Click en **Import Existing**
   - Nombre del cluster: `k8s-local`
   - Copiar el comando que genera

2. **En la VM de Vagrant:**
   ```bash
   # Pegar el comando copiado
   
   # Verificar que cattle-system esté corriendo
   kubectl get pods -n cattle-system
   ```

3. **Esperar 2-5 minutos** hasta que el cluster aparezca como **Active** en Rancher

### 8.3 Script de Inicio Automático

Crea un script para iniciar todo automáticamente:

```bash
cat > ~/start-minikube-rancher.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando Minikube..."
minikube start --driver=docker --memory=3000 --cpus=2

echo "✅ Verificando estado de Minikube..."
minikube status

echo "📊 Habilitando addons..."
minikube addons enable ingress
minikube addons enable metrics-server

echo "☸️ Verificando pods en microstore..."
kubectl get pods -n microstore

echo "🌐 IP de Minikube:"
minikube ip

echo "✅ Aplicación disponible en: http://192.168.56.10/"
echo "✅ Rancher disponible en: https://52.225.216.248"
EOF

chmod +x ~/start-minikube-rancher.sh
```

**Uso:**
```bash
~/start-minikube-rancher.sh
```

---

## 🔍 Comandos Útiles de Troubleshooting

### Ver logs de un pod específico
```bash
kubectl logs -n microstore <nombre-del-pod> --tail=50
```

### Ver logs en tiempo real
```bash
kubectl logs -n microstore <nombre-del-pod> -f
```

### Descripción detallada de un pod
```bash
kubectl describe pod -n microstore <nombre-del-pod>
```

### Reiniciar un deployment
```bash
kubectl rollout restart deployment <nombre-deployment> -n microstore
```

### Ver eventos del namespace
```bash
kubectl get events -n microstore --sort-by='.lastTimestamp'
```

### Ejecutar comando dentro de un pod
```bash
kubectl exec -it -n microstore <nombre-pod> -- /bin/bash
```

### Ver configuración de un Ingress
```bash
kubectl get ingress -n microstore
kubectl describe ingress <nombre-ingress> -n microstore
```

---

## 🛑 Detener y Limpiar

### Pausar Minikube (mantiene estado)
```bash
minikube stop
```

### Eliminar todo el cluster
```bash
minikube delete
```

### Apagar la VM
```bash
exit  # Salir de la VM
vagrant halt
```

### Destruir completamente la VM
```bash
vagrant destroy -f
```

---

## 📊 Arquitectura del Despliegue Local

```
┌─────────────────────────────────────────────────┐
│           VirtualBox (Host Machine)             │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │     Vagrant VM (Ubuntu 22.04)             │ │
│  │     IP: 192.168.56.10                     │ │
│  │                                           │ │
│  │  ┌─────────────────────────────────────┐ │ │
│  │  │    Minikube (Kubernetes)            │ │ │
│  │  │    Driver: Docker                   │ │ │
│  │  │                                     │ │ │
│  │  │  Namespace: microstore              │ │ │
│  │  │  ┌──────────────────────────────┐   │ │ │
│  │  │  │  MySQL StatefulSet (mysql-0) │   │ │ │
│  │  │  │  - Database: microstore      │   │ │ │
│  │  │  └──────────────────────────────┘   │ │ │
│  │  │                                     │ │ │
│  │  │  ┌──────────────────────────────┐   │ │ │
│  │  │  │  Microservicios (2 replicas) │   │ │ │
│  │  │  │  - users-deployment          │   │ │ │
│  │  │  │  - products-deployment       │   │ │ │
│  │  │  │  - orders-deployment         │   │ │ │
│  │  │  │  - frontend-deployment       │   │ │ │
│  │  │  └──────────────────────────────┘   │ │ │
│  │  │                                     │ │ │
│  │  │  ┌──────────────────────────────┐   │ │ │
│  │  │  │  Ingress Controller (NGINX)  │   │ │ │
│  │  │  │  - Rutas /api/*              │   │ │ │
│  │  │  │  - Ruta /                    │   │ │ │
│  │  │  └──────────────────────────────┘   │ │ │
│  │  └─────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
           ▲
           │ Acceso desde navegador
           │ http://192.168.56.10/
```

---

## 🔐 Credenciales por Defecto

### MySQL
- **Host:** `mysql-service`
- **Puerto:** `3306`
- **Usuario:** `root`
- **Contraseña:** `root`
- **Base de datos:** `microstore`

### Rancher (si aplica)
- **URL:** `https://52.225.216.248`
- **Usuario:** `admin`
- **Contraseña:** (configurada en la instalación de Rancher)

---

## 📝 Notas Importantes

1. **Primera vez:** El despliegue completo puede tomar 15-20 minutos
2. **RAM:** Asegúrate de tener suficiente memoria disponible
3. **Puerto 80:** No debe estar ocupado por otro servicio en tu máquina
4. **Firewall:** Verifica que VirtualBox pueda crear redes host-only
5. **Ingress:** Puede tardar 1-2 minutos en propagar las rutas después del despliegue

---

## 🆘 Problemas Comunes

### Problema: Pods en estado CrashLoopBackOff
**Solución:**
```bash
kubectl logs -n microstore <pod-name>
# Verificar errores de conexión a MySQL
# Asegurarse que mysql-0 esté Running antes de desplegar microservicios
```

### Problema: No puedo acceder a http://192.168.56.10/
**Solución:**
```bash
# Verificar que la VM esté corriendo
vagrant status

# Verificar que Minikube esté activo
vagrant ssh
minikube status

# Verificar Ingress
kubectl get ingress -n microstore
```

### Problema: "connection refused" al MySQL
**Solución:**
```bash
# Verificar que el secret tenga los valores correctos
kubectl get secret database-secret -n microstore -o yaml

# Verificar que mysql-0 esté Running
kubectl get pods -n microstore mysql-0

# Ver logs de MySQL
kubectl logs -n microstore mysql-0
```

---

## 📚 Referencias

- [Documentación de Minikube](https://minikube.sigs.k8s.io/docs/)
- [Documentación de Vagrant](https://www.vagrantup.com/docs)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Rancher Documentation](https://rancher.com/docs/)

---

**Autor:** Equipo de Desarrollo Cloud Computing  
**Última actualización:** Noviembre 8, 2025  
**Versión:** 1.0
