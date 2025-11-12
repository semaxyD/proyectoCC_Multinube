# 📚 ÍNDICE DE DOCUMENTACIÓN - MICROSTORE

## 🎯 INICIO RÁPIDO

### ¿Primera vez aquí?
👉 Comienza con **[RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md)** para entender qué se hizo y por qué.

### ¿Quieres desplegar ya?
👉 Ve directo a **[QUICK_START.md](QUICK_START.md)** y ejecuta `./quickstart.sh`

### ¿Tienes que sustentar pronto?
👉 Lee **[CHECKLIST_SUSTENTACION.md](CHECKLIST_SUSTENTACION.md)** para prepararte.

---

## 📖 DOCUMENTACIÓN COMPLETA

### 1. **Documentos de Inicio** ⭐ EMPEZAR AQUÍ

| Documento | Descripción | Tiempo de Lectura |
|-----------|-------------|-------------------|
| **[RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md)** | Resumen de todo el proyecto | 5 minutos |
| **[QUICK_START.md](QUICK_START.md)** | Inicio en 3 pasos | 2 minutos |
| **[INDEX.md](INDEX.md)** | Este archivo - Mapa de navegación | 3 minutos |

### 2. **Guías de Despliegue** 🚀 PARA IMPLEMENTAR

| Documento | Descripción | Cuándo Usar |
|-----------|-------------|-------------|
| **[GUIA_DESPLIEGUE_COMPLETA.md](GUIA_DESPLIEGUE_COMPLETA.md)** | Guía paso a paso detallada | Cuando necesitas entender cada paso |
| **Scripts** (ver abajo) | Scripts automatizados | Para desplegar rápidamente |

### 3. **Solución de Problemas** 🔧 CUANDO ALGO FALLA

| Documento | Descripción | Cuándo Usar |
|-----------|-------------|-------------|
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | 14+ problemas comunes resueltos | Cuando algo no funciona |
| **[DEPLOYMENT_FIXES.md](DEPLOYMENT_FIXES.md)** | Fixes anteriores aplicados | Para contexto histórico |

### 4. **Preparación para Sustentación** 🎓 ANTES DE PRESENTAR

| Documento | Descripción | Cuándo Usar |
|-----------|-------------|-------------|
| **[CHECKLIST_SUSTENTACION.md](CHECKLIST_SUSTENTACION.md)** | Lista completa de verificación | 2-3 días antes de sustentar |
| **[CORRECCIONES.md](CORRECCIONES.md)** | Resumen de mejoras implementadas | Para explicar cambios |

### 5. **Documentación Original** 📘 REFERENCIA

| Documento | Descripción | Cuándo Usar |
|-----------|-------------|-------------|
| **[README.md](README.md)** | Documentación original del proyecto | Para contexto general |
| **[INFRASTRUCTURE.md](INFRASTRUCTURE.md)** | Infraestructura con Rancher | Para setup de Rancher |
| **[WINDOWS-GUIDE.md](WINDOWS-GUIDE.md)** | Guía específica para Windows | Si usas Windows |

### 6. **Configuración Técnica** ⚙️ PARA DESARROLLADORES

| Ubicación | Descripción | Cuándo Usar |
|-----------|-------------|-------------|
| **[k8s/overlays/](k8s/overlays/)** | Configuraciones por entorno | Para personalizar |
| **[k8s/overlays/README.md](k8s/overlays/README.md)** | Documentación de Kustomize | Para entender overlays |

---

## 🔧 SCRIPTS DISPONIBLES

### Scripts Principales

```bash
# 1️⃣ QUICKSTART - Asistente interactivo
./quickstart.sh

# 2️⃣ MENÚ COMPLETO - 5 opciones
./scripts/deploy-unified.sh

# 3️⃣ MINIKUBE - Despliegue directo local
./scripts/deploy-minikube.sh

# 4️⃣ AZURE AKS - Despliegue directo nube
./scripts/deploy-aks.sh
```

### Scripts de Soporte

```bash
# Construir imágenes (Linux/Mac)
./scripts/build-images.sh

# Construir imágenes (Windows)
./scripts/build-images.ps1

# Configurar kubectl
./scripts/setup-k8s.sh

# Limpiar recursos
./scripts/cleanup.sh

# Validar antes de desplegar
./scripts/validate-local.sh
```

---

## 🗺️ FLUJO DE TRABAJO RECOMENDADO

### Para Aprender el Proyecto (Primera Vez)

```
1. RESUMEN_EJECUTIVO.md
   ↓
2. QUICK_START.md
   ↓
3. Ejecutar: ./quickstart.sh (Minikube)
   ↓
4. GUIA_DESPLIEGUE_COMPLETA.md (solo sección Minikube)
   ↓
5. Explorar la aplicación desplegada
   ↓
6. Si hay problemas → TROUBLESHOOTING.md
```

### Para Desplegar en Azure

```
1. GUIA_DESPLIEGUE_COMPLETA.md (sección Azure)
   ↓
2. Verificar prerequisitos de Azure
   ↓
3. Ejecutar: ./scripts/deploy-aks.sh
   ↓
4. Si hay problemas → TROUBLESHOOTING.md (sección Azure)
   ↓
5. Registrar en Rancher → INFRASTRUCTURE.md
```

### Para Preparar Sustentación

```
1. CHECKLIST_SUSTENTACION.md (Leer completo)
   ↓
2. Verificar prerequisitos (2 días antes)
   ↓
3. Hacer despliegue de prueba completo (1 día antes)
   ↓
4. Preparar respuestas a preguntas (1 día antes)
   ↓
5. Verificar que todo funciona (1 hora antes)
   ↓
6. Tener URLs y comandos listos
```

### Para Troubleshooting

```
Error detectado
   ↓
1. Leer mensaje de error del script
   ↓
2. Buscar en TROUBLESHOOTING.md
   ↓
3. Aplicar solución propuesta
   ↓
4. Si persiste → Comandos de debugging
   ↓
5. Último recurso → Eliminar y recrear
```

---

## 📊 MAPA DE DECISIONES

### ¿Qué documento necesito?

```
┌─────────────────────────────────────────┐
│ ¿Qué quieres hacer?                     │
└─────────────────────────────────────────┘
              ↓
    ┌─────────┴─────────┐
    │                   │
    ↓                   ↓
¿Desplegar?         ¿Entender?
    │                   │
    ↓                   ↓
QUICK_START.md    RESUMEN_EJECUTIVO.md
    │                   │
    ↓                   ↓
./quickstart.sh   GUIA_DESPLIEGUE...
    │
    ↓
  ¿Falló?
    │
    ↓
TROUBLESHOOTING.md
```

### ¿Qué entorno usar?

```
┌─────────────────────────────────────────┐
│ ¿Dónde quieres desplegar?               │
└─────────────────────────────────────────┘
              ↓
    ┌─────────┴─────────┬──────────┐
    │                   │          │
    ↓                   ↓          ↓
  Local              Azure        AWS
    │                   │          │
    ↓                   ↓          ↓
Minikube            AKS          EKS
    │                   │          │
    ↓                   ↓          ↓
deploy-           deploy-      (futuro)
minikube.sh       aks.sh
```

---

## 🎯 CASOS DE USO COMUNES

### Caso 1: "Quiero probar rápido en mi laptop"
```bash
# Solución en 2 comandos:
chmod +x quickstart.sh
./quickstart.sh
# Seleccionar: 1 (Minikube)
```
📖 Leer: **QUICK_START.md**

---

### Caso 2: "Necesito desplegar en Azure para la clase"
```bash
# Solución:
./scripts/deploy-aks.sh
# Seguir las instrucciones del script
```
📖 Leer: **GUIA_DESPLIEGUE_COMPLETA.md** (sección Azure)

---

### Caso 3: "Algo no funciona y no sé qué hacer"
```bash
# 1. Ver estado
kubectl get all -n microstore

# 2. Ver logs
kubectl logs -f deployment/<service>-deployment -n microstore

# 3. Buscar en docs
```
📖 Leer: **TROUBLESHOOTING.md**

---

### Caso 4: "Sustento mañana y estoy nervioso"
```
1. Lee CHECKLIST_SUSTENTACION.md (ahora)
2. Verifica que todo funciona (hoy)
3. Practica la demo (hoy)
4. Prepara respuestas a preguntas (hoy)
5. Duerme bien (importante!)
```
📖 Leer: **CHECKLIST_SUSTENTACION.md**

---

### Caso 5: "Quiero entender qué se corrigió"
```
1. Lee RESUMEN_EJECUTIVO.md
2. Lee CORRECCIONES.md
3. Compara archivos antes/después en Git
```
📖 Leer: **CORRECCIONES.md** + **RESUMEN_EJECUTIVO.md**

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
📂 microProyecto2_CloudComputing/
│
├── 📖 DOCUMENTACIÓN PRINCIPAL (Leer primero) ⭐
│   ├── INDEX.md                          ← Estás aquí
│   ├── RESUMEN_EJECUTIVO.md              ← Empezar aquí
│   ├── QUICK_START.md                    ← Para desplegar rápido
│   ├── GUIA_DESPLIEGUE_COMPLETA.md       ← Guía paso a paso
│   ├── TROUBLESHOOTING.md                ← Cuando falla algo
│   ├── CHECKLIST_SUSTENTACION.md         ← Antes de sustentar
│   ├── CORRECCIONES.md                   ← Qué se cambió
│   │
│   ├── README.md                         ← Doc original
│   ├── INFRASTRUCTURE.md                 ← Setup Rancher
│   ├── WINDOWS-GUIDE.md                  ← Específico Windows
│   └── DEPLOYMENT_FIXES.md               ← Fixes anteriores
│
├── 🔧 SCRIPTS (Ejecutar estos) ⭐
│   ├── quickstart.sh                     ← Inicio rápido
│   └── scripts/
│       ├── deploy-unified.sh             ← Menú completo
│       ├── deploy-minikube.sh            ← Deploy local
│       ├── deploy-aks.sh                 ← Deploy Azure
│       ├── build-images.sh
│       ├── build-images.ps1
│       ├── setup-k8s.sh
│       ├── cleanup.sh
│       └── validate-local.sh
│
├── ⚙️ CONFIGURACIÓN KUBERNETES
│   └── k8s/
│       ├── common/                       ← Secrets, ConfigMaps
│       ├── mysql/                        ← Base de datos
│       ├── frontend/                     ← Frontend web
│       ├── users/                        ← Microservicio users
│       ├── products/                     ← Microservicio products
│       ├── orders/                       ← Microservicio orders
│       └── overlays/                     ← Config por entorno ⭐
│           ├── README.md
│           ├── minikube/
│           └── azure/
│
├── 🏗️ INFRAESTRUCTURA
│   └── infra/terraform/                  ← IaC para Azure
│
└── 🐳 CÓDIGO DE LA APLICACIÓN
    ├── frontend/                         ← App web Flask
    ├── microUsers/                       ← API usuarios
    ├── microProducts/                    ← API productos
    └── microOrders/                      ← API órdenes
```

---

## ⏱️ TIEMPO ESTIMADO POR TAREA

| Tarea | Tiempo | Documentos Necesarios |
|-------|--------|----------------------|
| Entender el proyecto | 30 min | RESUMEN_EJECUTIVO.md, INDEX.md |
| Primer despliegue en Minikube | 15 min | QUICK_START.md, quickstart.sh |
| Despliegue completo en Azure | 45 min | GUIA_DESPLIEGUE_COMPLETA.md |
| Configurar Rancher | 30 min | INFRASTRUCTURE.md |
| Aprender troubleshooting | 30 min | TROUBLESHOOTING.md |
| Preparar sustentación | 2 horas | CHECKLIST_SUSTENTACION.md |
| **TOTAL** | **~5 horas** | Todos los documentos |

---

## 🎓 NIVELES DE CONOCIMIENTO

### Nivel 1: Principiante
**"Nunca he usado Kubernetes"**

Leer en orden:
1. RESUMEN_EJECUTIVO.md
2. QUICK_START.md
3. Ejecutar: `./quickstart.sh` (Minikube)
4. GUIA_DESPLIEGUE_COMPLETA.md (sección Minikube)

---

### Nivel 2: Intermedio
**"Conozco Kubernetes básico"**

Leer en orden:
1. QUICK_START.md
2. Ejecutar scripts para ambos entornos
3. GUIA_DESPLIEGUE_COMPLETA.md (completa)
4. k8s/overlays/README.md

---

### Nivel 3: Avanzado
**"Quiero entender todo y personalizarlo"**

Leer en orden:
1. CORRECCIONES.md
2. GUIA_DESPLIEGUE_COMPLETA.md
3. k8s/overlays/README.md
4. Código de scripts
5. Manifiestos de Kubernetes

---

## 🆘 AYUDA RÁPIDA

### ❓ "¿Por dónde empiezo?"
→ **RESUMEN_EJECUTIVO.md** luego **QUICK_START.md**

### ❓ "¿Cómo despliego?"
→ Ejecutar: `./quickstart.sh`

### ❓ "¿Algo falló, qué hago?"
→ **TROUBLESHOOTING.md**

### ❓ "¿Cómo me preparo para sustentar?"
→ **CHECKLIST_SUSTENTACION.md**

### ❓ "¿Qué se corrigió en el proyecto?"
→ **CORRECCIONES.md**

### ❓ "¿Quiero entender cada paso del despliegue?"
→ **GUIA_DESPLIEGUE_COMPLETA.md**

### ❓ "¿Cómo personalizo la configuración?"
→ **k8s/overlays/README.md**

---

## 🎯 PRÓXIMOS PASOS SUGERIDOS

### Si es tu primera vez:
1. ✅ Leer este INDEX.md (5 min)
2. ✅ Leer RESUMEN_EJECUTIVO.md (10 min)
3. ✅ Ejecutar `./quickstart.sh` (10 min)
4. ✅ Explorar la aplicación (10 min)

### Si ya desplegaste en Minikube:
1. ✅ Leer GUIA_DESPLIEGUE_COMPLETA.md (sección Azure)
2. ✅ Configurar Azure CLI
3. ✅ Ejecutar `./scripts/deploy-aks.sh`
4. ✅ Registrar en Rancher

### Si tienes que sustentar pronto:
1. ✅ Leer CHECKLIST_SUSTENTACION.md
2. ✅ Verificar que todo funciona
3. ✅ Practicar demo
4. ✅ Preparar respuestas

---

## 📞 CONTACTO Y SOPORTE

### Recursos del Proyecto
- 📖 Documentación: Ver archivos .md
- 🔧 Scripts: Ver carpeta scripts/
- ⚙️ Configuración: Ver k8s/overlays/

### Recursos Externos
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
- [Azure AKS Docs](https://docs.microsoft.com/azure/aks/)
- [Rancher Docs](https://rancher.com/docs/)

---

**🚀 ¡Comienza tu viaje aquí!**

Recomendación: Empieza con **[RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md)** →  luego **[QUICK_START.md](QUICK_START.md)** → y ejecuta `./quickstart.sh`

¡Éxito con tu proyecto! ✨
