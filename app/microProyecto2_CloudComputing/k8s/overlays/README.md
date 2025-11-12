# Overlays de Kubernetes con Kustomize

Este directorio contiene configuraciones específicas para diferentes entornos de despliegue usando Kustomize.

## 📁 Estructura

```
overlays/
├── minikube/           # Configuración para Minikube (local)
│   └── kustomization.yaml
├── azure/              # Configuración para Azure AKS
│   └── kustomization.yaml
└── aws/                # Configuración para AWS EKS (futuro)
    └── kustomization.yaml
```

## 🎯 ¿Qué es Kustomize?

Kustomize es una herramienta para personalizar configuraciones de Kubernetes sin modificar los archivos YAML originales. Permite:

- Mantener una base común de manifiestos
- Aplicar cambios específicos por entorno
- No requiere templating (a diferencia de Helm)
- Integrado nativamente en `kubectl`

## 🚀 Uso

### Desplegar en Minikube

```bash
# Vista previa de los manifiestos generados
kubectl kustomize k8s/overlays/minikube

# Aplicar configuración de Minikube
kubectl apply -k k8s/overlays/minikube
```

### Desplegar en Azure AKS

```bash
# Vista previa de los manifiestos generados
kubectl kustomize k8s/overlays/azure

# Aplicar configuración de Azure
kubectl apply -k k8s/overlays/azure
```

## 🔧 Diferencias por Entorno

### Minikube
- **imagePullPolicy**: `Never` (usa imágenes locales)
- **Image names**: Sin registry prefix (ej: `microstore-users:latest`)
- **EXTERNAL_IP**: Se obtiene de `minikube ip`
- **Resources**: Ajustados para desarrollo local

### Azure AKS
- **imagePullPolicy**: `Always` (descarga desde ACR)
- **Image names**: Con registry prefix (ej: `myacr.azurecr.io/microstore-users:latest`)
- **EXTERNAL_IP**: Se obtiene del LoadBalancer de Azure
- **Resources**: Configurados para producción

## 📝 Modificar Configuraciones

Si necesitas ajustar configuraciones específicas:

1. **Edita el kustomization.yaml correspondiente**:
   ```bash
   # Para Minikube
   code k8s/overlays/minikube/kustomization.yaml
   
   # Para Azure
   code k8s/overlays/azure/kustomization.yaml
   ```

2. **Agrega patches personalizados**:
   ```yaml
   patches:
     - target:
         kind: Deployment
         name: frontend-deployment
       patch: |-
         - op: replace
           path: /spec/replicas
           value: 3
   ```

3. **Prueba los cambios**:
   ```bash
   kubectl kustomize k8s/overlays/minikube | less
   ```

## 🔍 Comandos Útiles

```bash
# Ver diferencias entre base y overlay
diff <(kubectl kustomize k8s) <(kubectl kustomize k8s/overlays/minikube)

# Validar sintaxis
kubectl kustomize k8s/overlays/minikube | kubectl apply --dry-run=client -f -

# Eliminar recursos desplegados
kubectl delete -k k8s/overlays/minikube
```

## ⚙️ Integración con Scripts

Los scripts de despliegue (`deploy-minikube.sh` y `deploy-aks.sh`) pueden usar estas configuraciones:

```bash
# En lugar de:
kubectl apply -f k8s/users/
kubectl apply -f k8s/products/
# ...

# Usar:
kubectl apply -k k8s/overlays/minikube
```

## 📚 Referencias

- [Documentación oficial de Kustomize](https://kustomize.io/)
- [Kustomize en Kubernetes](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
