#!/bin/bash

# Colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║   ███╗   ███╗██╗ ██████╗██████╗  ██████╗ ███████╗████████╗ ██████╗  ║
║   ████╗ ████║██║██╔════╝██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔═══██╗ ║
║   ██╔████╔██║██║██║     ██████╔╝██║   ██║███████╗   ██║   ██║   ██║ ║
║   ██║╚██╔╝██║██║██║     ██╔══██╗██║   ██║╚════██║   ██║   ██║   ██║ ║
║   ██║ ╚═╝ ██║██║╚██████╗██║  ██║╚██████╔╝███████║   ██║   ╚██████╔╝ ║
║   ╚═╝     ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝  ║
║                                                                       ║
║              🚀 QUICKSTART - DESPLIEGUE RÁPIDO                       ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}¡Bienvenido al asistente de despliegue rápido de MicroStore!${NC}"
echo ""
echo "Este script te ayudará a desplegar la aplicación en minutos."
echo ""

# Función para verificar comando
check_cmd() {
    if command -v $1 &> /dev/null; then
        echo -e "  ✅ $1"
        return 0
    else
        echo -e "  ❌ $1 ${YELLOW}(no instalado)${NC}"
        return 1
    fi
}

# Verificar prerequisitos
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 VERIFICANDO PREREQUISITOS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

has_kubectl=false
has_docker=false
has_minikube=false
has_az=false

check_cmd kubectl && has_kubectl=true
check_cmd docker && has_docker=true
check_cmd minikube && has_minikube=true
check_cmd az && has_az=true

echo ""

# Determinar entornos disponibles
envs_available=()
if [ "$has_kubectl" = true ] && [ "$has_docker" = true ] && [ "$has_minikube" = true ]; then
    envs_available+=("minikube")
fi

if [ "$has_kubectl" = true ] && [ "$has_docker" = true ] && [ "$has_az" = true ]; then
    envs_available+=("azure")
fi

if [ ${#envs_available[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No se detectaron los prerequisitos necesarios${NC}"
    echo ""
    echo "Para desplegar necesitas:"
    echo "  • kubectl (siempre)"
    echo "  • docker (siempre)"
    echo "  • minikube (para despliegue local)"
    echo "  • az (para despliegue en Azure)"
    echo ""
    echo "Instalación rápida:"
    echo ""
    echo "  Ubuntu/Debian:"
    echo "    sudo apt-get install -y kubectl docker.io"
    echo "    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    echo "    sudo install minikube-linux-amd64 /usr/local/bin/minikube"
    echo ""
    echo "  macOS (con Homebrew):"
    echo "    brew install kubectl docker minikube azure-cli"
    echo ""
    echo "  Windows (con Chocolatey):"
    echo "    choco install kubernetes-cli docker-desktop minikube azure-cli"
    echo ""
    exit 1
fi

# Mostrar entornos disponibles
echo -e "${GREEN}✅ Entornos disponibles para despliegue:${NC}"
echo ""
for env in "${envs_available[@]}"; do
    if [ "$env" = "minikube" ]; then
        echo -e "  🏠 ${GREEN}Minikube${NC} - Cluster local para desarrollo"
    elif [ "$env" = "azure" ]; then
        echo -e "  ☁️  ${GREEN}Azure AKS${NC} - Cluster en la nube"
    fi
done
echo ""

# Seleccionar entorno
if [ ${#envs_available[@]} -eq 1 ]; then
    SELECTED_ENV="${envs_available[0]}"
    echo -e "${CYAN}Solo hay un entorno disponible: $SELECTED_ENV${NC}"
else
    echo -e "${YELLOW}Selecciona el entorno de despliegue:${NC}"
    echo "  1) Minikube (local)"
    echo "  2) Azure AKS (nube)"
    echo ""
    echo -n "Opción [1-2]: "
    read -r choice
    
    case $choice in
        1)
            SELECTED_ENV="minikube"
            ;;
        2)
            SELECTED_ENV="azure"
            ;;
        *)
            echo "Opción inválida"
            exit 1
            ;;
    esac
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 INICIANDO DESPLIEGUE EN: $(echo $SELECTED_ENV | tr '[:lower:]' '[:upper:]')${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Dar permisos de ejecución a los scripts
chmod +x scripts/*.sh 2>/dev/null

# Ejecutar script correspondiente
if [ "$SELECTED_ENV" = "minikube" ]; then
    if [ -f "scripts/deploy-minikube.sh" ]; then
        ./scripts/deploy-minikube.sh
    else
        echo "Error: No se encuentra scripts/deploy-minikube.sh"
        exit 1
    fi
elif [ "$SELECTED_ENV" = "azure" ]; then
    if [ -f "scripts/deploy-aks.sh" ]; then
        ./scripts/deploy-aks.sh
    else
        echo "Error: No se encuentra scripts/deploy-aks.sh"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ QUICKSTART COMPLETADO${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📚 Documentación disponible:${NC}"
echo "  • GUIA_DESPLIEGUE_COMPLETA.md - Guía detallada paso a paso"
echo "  • TROUBLESHOOTING.md - Solución de problemas"
echo "  • CORRECCIONES.md - Resumen de correcciones aplicadas"
echo ""
echo -e "${CYAN}🔧 Scripts útiles:${NC}"
echo "  • ./scripts/deploy-unified.sh - Menú interactivo completo"
echo "  • ./scripts/deploy-minikube.sh - Desplegar en Minikube"
echo "  • ./scripts/deploy-aks.sh - Desplegar en Azure AKS"
echo ""
