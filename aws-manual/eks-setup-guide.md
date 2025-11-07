# Guía de Creación de Cluster EKS en AWS Academy

Debido a las limitaciones de AWS Academy (no se puede usar Terraform con roles educativos), el cluster EKS debe crearse **manualmente** desde la consola de AWS.

> ⚠️ **Importante**: AWS Academy usa **Configuración Rápida con Modo Automático de EKS** que simplifica el proceso y automatiza la creación de nodos. Muchas opciones están preconfiguradas y no pueden modificarse.

## 📋 Requisitos Previos

- Cuenta de AWS Academy activada
- Acceso a AWS Console
- AWS CloudShell habilitado
- `kubectl` instalado (disponible en CloudShell)

## 🚀 Paso 1: Crear el Cluster EKS (Configuración Simplificada)

### 1.1 Acceder a la consola de EKS

1. Ingresar a AWS Console
2. Buscar servicio **"EKS"** (Elastic Kubernetes Service)
3. Click en **"Add cluster"** → **"Create"**

### 1.2 Opciones de Configuración

**Seleccionar**: 
- ✅ **"Configuración rápida (con modo automático EKS)"**

> 💡 Esta opción crea rápidamente un clúster con configuración predeterminada de calidad de producción. El modo automático automatiza tareas de infraestructura como creación de nodos y aprovisionamiento de almacenamiento.

### 1.3 Configuración del Clúster

Complete los siguientes campos (los únicos editables):

| Campo | Valor Sugerido | Descripción |
|-------|----------------|-------------|
| **Nombre** | `rancher-eks-cluster` | Nombre único del cluster (máx. 100 caracteres) |
| **Versión de Kubernetes** | `1.33` | Versión más reciente disponible |
| **Rol de IAM del clúster** | `LabEksClusterRole-*` | Ya preconfigurado por AWS Academy |
| **Rol de IAM del nodo** | `LabEksNodeRole-*` | Ya preconfigurado por AWS Academy |

### 1.4 Configuración de Red

| Campo | Valor | Descripción |
|-------|-------|-------------|
| **VPC** | VPC predeterminada | Seleccionar la VPC default (ej: `vpc-0fca6a11cfbf47a1f`) |
| **Subredes** | Seleccionar TODAS | Marcar todas las subnets públicas disponibles |

**Subredes disponibles** (seleccionar todas las que aparezcan):
- `subnet-033b244b457b1d437` (us-east-1b) 172.31.80.0/20 - Tipo: Público
- `subnet-0d3554c92ec74c89e` (us-east-1a) 172.31.0.0/20 - Tipo: Público
- `subnet-02c09c2f5a0e66aaa` (us-east-1f) 172.31.64.0/20 - Tipo: Público
- `subnet-060984bfac4e63952` (us-east-1c) 172.31.16.0/20 - Tipo: Público
- `subnet-03c2906d0c6417eda` (us-east-1d) 172.31.32.0/20 - Tipo: Público

> ℹ️ Las subredes específicas pueden variar según tu cuenta de AWS Academy. Asegúrate de seleccionar TODAS las disponibles.

### 1.5 Revisar Configuración Predeterminada

El modo automático de EKS configura automáticamente (no es necesario configurar manualmente):

#### Capacidades Incluidas Automáticamente:

| Característica | Valor Predeterminado | ¿Se puede editar después? |
|----------------|----------------------|---------------------------|
| Modo automático de EKS | Habilitado | ✅ Sí |
| Rol de IAM del clúster | LabEksClusterRole | ❌ No |
| Rol de IAM del nodo | LabEksNodeRole | ❌ No |
| **Grupos de nodos** | general-purpose, system | ✅ Sí |
| Acceso administrador | Permitir al creador | ✅ Sí |
| Modo de autenticación | API de EKS | ❌ No |
| Protección contra eliminaciones | Desactivado | ✅ Sí |
| Clave de cifrado | Propiedad de AWS | ✅ Sí |
| Política de actualización | Soporte estándar | ✅ Sí |
| Cambio de zona de ARC | Habilitado | ✅ Sí |
| Complementos comunitarios | metrics-server | ✅ Sí |

#### Configuración de Red Automática:

| Campo | Valor | ¿Se puede editar después? |
|-------|-------|---------------------------|
| Grupos de seguridad | Creados automáticamente | ✅ Sí |
| Acceso al endpoint | Público y privado | ✅ Sí |
| Familia de direcciones IP | IPv4 | ❌ No |
| Orígenes de acceso público | 0.0.0.0/0 | ✅ Sí |

#### Observabilidad:

| Campo | Valor | ¿Se puede editar después? |
|-------|-------|---------------------------|
| Registro de clústeres | api, audit, authenticator, controllerManager, scheduler | ✅ Sí |

### 1.6 Crear el Cluster

1. Revisar toda la configuración
2. Click en **"Crear clúster"**
3. Esperar a que el cluster se cree

⏳ **Tiempo de creación: 10-15 minutos**

> 💡 **Nota Importante**: Con el modo automático, **NO necesitas crear node groups manualmente**. AWS crea automáticamente dos grupos de nodos:
> - `general-purpose`: Para cargas de trabajo generales
> - `system`: Para componentes del sistema

## 🎉 ¡No hay Paso 2!

A diferencia del proceso manual tradicional, **NO necesitas crear node groups** porque el modo automático de EKS ya los creó por ti.

## 🔧 Paso 2: Configurar kubectl

### 3.1 Desde AWS CloudShell

1. Abrir **AWS CloudShell** (icono en la barra superior)
2. Esperar a que se inicialice
3. Configurar kubectl:

```bash
# Configurar credenciales para el cluster
aws eks update-kubeconfig --region us-east-1 --name rancher-eks-cluster

# Verificar conexión
kubectl get nodes -o wide
```

**Salida esperada:**
```
NAME                              STATUS   ROLES    AGE   VERSION
eks-general-purpose-xxxxx         Ready    <none>   5m    v1.33.x
eks-system-xxxxx                  Ready    <none>   5m    v1.33.x
```

> 💡 **Nota**: Los nodos se crean automáticamente con el modo automático de EKS. Verás nodos de los grupos `general-purpose` y `system`.

### 3.2 Desde máquina local (Opcional)

Si tienes AWS CLI configurado localmente:

```bash
# Configurar credenciales de AWS Academy
aws configure
# Ingresar: Access Key ID, Secret Access Key, Region (us-east-1)

# Obtener kubeconfig
aws eks update-kubeconfig --region us-east-1 --name rancher-eks-cluster

# Verificar
kubectl get nodes
```

## 🔗 Paso 4: Registrar Cluster en Rancher

### 4.1 Desde Rancher UI

1. Acceder a Rancher: `https://<RANCHER_IP>`
2. Ir a **Clusters** → **Import Existing**
3. Seleccionar **"Generic"**
4. Nombrar el cluster: `rancher-eks-cluster`
5. Agregar descripción (opcional)
6. Click **"Create"**

### 4.2 Aplicar Configuración de Rancher

Copiar el comando proporcionado por Rancher y ejecutarlo en **AWS CloudShell**:

```bash
# Asegurarse de estar en el contexto correcto
kubectl config current-context

# Ejecutar comando de Rancher (ejemplo)
curl --insecure -sfL https://<RANCHER_IP>/v3/import/<TOKEN>.yaml | kubectl apply -f -
```

### 4.3 Verificar Registro

```bash
# Esperar a que se cree el namespace
kubectl get namespace cattle-system

# Ver pods de Rancher agents
kubectl get pods -n cattle-system

# Esperar a que estén Running
kubectl wait --for=condition=Ready pod -l app=cattle-cluster-agent -n cattle-system --timeout=300s
```

**En Rancher UI**, el cluster debe aparecer como **Active** en 2-3 minutos.

## ✅ Paso 5: Verificación

### 5.1 Verificación Básica

```bash
# Ver todos los nodos
kubectl get nodes -o wide

# Ver todos los pods del sistema
kubectl get pods -A

# Ver servicios
kubectl get svc -A
```

### 5.2 Test de Despliegue

```bash
# Crear pod de prueba
kubectl run test-nginx --image=nginx --port=80

# Verificar que esté corriendo
kubectl get pods

# Ver logs
kubectl logs test-nginx

# Limpiar
kubectl delete pod test-nginx
```

### 5.3 Test con LoadBalancer (Opcional)

```bash
# Crear deployment
kubectl create deployment hello-eks --image=nginxdemos/hello --port=80

# Exponer con LoadBalancer
kubectl expose deployment hello-eks --type=LoadBalancer --port=80

# Obtener la URL (puede tardar 2-3 minutos)
kubectl get svc hello-eks -w

# Cuando aparezca EXTERNAL-IP, acceder desde navegador
```

## 🛠️ Comandos Útiles

### Información del Cluster

```bash
# Ver información del cluster
aws eks describe-cluster --name rancher-eks-cluster --region us-east-1

# Ver node groups (creados automáticamente)
aws eks list-nodegroups --cluster-name rancher-eks-cluster --region us-east-1

# Describe un node group específico
aws eks describe-nodegroup \
  --cluster-name rancher-eks-cluster \
  --nodegroup-name eks-general-purpose \
  --region us-east-1
```

### Gestión de Contextos

```bash
# Listar contextos
kubectl config get-contexts

# Cambiar de contexto
kubectl config use-context <context-name>

# Ver contexto actual
kubectl config current-context
```

### Debugging

```bash
# Logs de un nodo
kubectl describe node <node-name>

# Logs de pods problemáticos
kubectl logs <pod-name> -n <namespace>

# Eventos del cluster
kubectl get events --sort-by='.lastTimestamp'
```

## 🐛 Troubleshooting

### Problema: Nodos NotReady

```bash
# Ver estado detallado
kubectl describe node <node-name>

# Listar node groups automáticos
aws eks list-nodegroups --cluster-name rancher-eks-cluster --region us-east-1
```

**Solución**: Esperar 5-10 minutos. Los nodos se crean automáticamente con el modo automático de EKS.

### Problema: No se puede conectar con kubectl

```bash
# Re-configurar kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name rancher-eks-cluster \
  --overwrite-existing

# Verificar credenciales de AWS
aws sts get-caller-identity
```

### Problema: Pods de Rancher no se despliegan

```bash
# Verificar namespace
kubectl get namespace cattle-system

# Ver eventos
kubectl get events -n cattle-system

# Ver logs
kubectl logs -l app=cattle-cluster-agent -n cattle-system
```

**Solución**: Verificar que Rancher server sea accesible desde AWS (puertos 443 y 6443 abiertos).

### Problema: LoadBalancer sin IP Externa

```bash
# Ver servicio
kubectl describe svc <service-name>

# Verificar que el security group permita tráfico
```

**Solución**: AWS puede tardar 2-5 minutos en asignar IP externa.

## 💰 Costos y Gestión

### Costos Aproximados (AWS Academy)

- **Control Plane**: Gratis (incluido en créditos)
- **Nodos EC2**: ~$0.04/hora por nodo t3.medium
- **EBS Volumes**: ~$0.10/GB/mes
- **Data Transfer**: Mínimo para testing

**Total estimado**: ~$2-3/día con 2 nodos

### Apagar el Cluster (sin eliminarlo)

**⚠️ Con modo automático, no puedes escalar a 0 nodos manualmente**. Los node groups son gestionados automáticamente por EKS.

**Alternativa**: Eliminar y recrear el cluster cuando lo necesites (solo toma 5-10 minutos con auto-mode).

### Eliminar el Cluster

**⚠️ CUIDADO: Esto elimina TODOS los recursos**

```bash
# 1. Desregistrar de Rancher (si está registrado)
# Hacerlo desde Rancher UI

# 2. Eliminar el cluster (EKS auto-mode eliminará los node groups automáticamente)
aws eks delete-nodegroup \
  --cluster-name rancher-eks-cluster \
  --nodegroup-name rancher-eks-nodes \
  --region us-east-1

# Esperar a que se elimine (5-10 min)

# 2. Eliminar cluster
aws eks delete-cluster \
  --name rancher-eks-cluster \
  --region us-east-1
```

## 📚 Referencias

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS Academy Best Practices](https://awsacademy.instructure.com/)
- [Rancher EKS Integration](https://rancher.com/docs/rancher/v2.8/en/cluster-provisioning/hosted-kubernetes-clusters/eks/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## 📝 Notas Importantes

1. **AWS Academy tiene limitaciones**:
   - No se puede usar Terraform con LabRole
   - Los recursos se eliminan al terminar el lab
   - Créditos limitados
   - **Usa el modo automático** para simplificar la creación

2. **Modo Automático de EKS**:
   - Crea automáticamente node groups (general-purpose y system)
   - No requiere configuración manual de VPC, subnets ni security groups
   - Usa Kubernetes 1.33 por defecto
   - Ideal para AWS Academy

3. **Costos**:
   - Monitorear uso de créditos regularmente
   - Eliminar recursos cuando no se usen
   - Recrear el cluster es rápido (5-10 minutos)

4. **Persistencia**:
   - Los clusters de AWS Academy NO persisten entre sesiones
   - Hacer backup de configuraciones importantes
   - Considerar exportar manifests de aplicaciones críticas

---
