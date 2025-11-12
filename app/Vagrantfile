# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "k8slocal-vm"

  # 💻 Red Bridge (para acceso desde Rancher)
  config.vm.network "public_network", bridge: "Automatic"
  
  # 🌐 Red privada para acceso directo desde Windows
  config.vm.network "private_network", ip: "192.168.56.10"
  
  # 🔌 Port forwarding para acceder a servicios desde Windows
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 80, host: 9080
  config.vm.network "forwarded_port", guest: 443, host: 8443

  # 📦 Carpeta compartida - CLAVE para acceder a MicroProyecto2
  # Sincroniza toda la carpeta ProyectoFinal dentro de /vagrant
  config.vm.synced_folder ".", "/vagrant"

  # 💪 Recursos aumentados (Kubernetes + 4 microservicios + MySQL)
  config.vm.provider "virtualbox" do |vb|
    vb.name = "k8sLocal-MicroStore"
    vb.memory = 4144      # 4GB RAM (necesario para K8s + microservicios)
    vb.cpus = 4           # 4 CPUs para mejor rendimiento
  end

  # 🚀 Script de provisión principal
  config.vm.provision "shell", path: "create_k8sLocal.sh"
  
  # 🔧 Post-provisión: configurar permisos y mostrar info
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # Dar permisos a scripts de MicroProyecto2
    if [ -d /vagrant/microProyecto2_CloudComputing ]; then
      chmod +x /vagrant/microProyecto2_CloudComputing/*.sh 2>/dev/null || true
      chmod +x /vagrant/microProyecto2_CloudComputing/scripts/*.sh 2>/dev/null || true
    fi
    
    # Configurar alias útiles
    echo "alias k='kubectl'" >> ~/.bashrc
    echo "alias kgp='kubectl get pods -A'" >> ~/.bashrc
    echo "alias kgs='kubectl get svc -A'" >> ~/.bashrc
    echo "alias mk='minikube -p k8sLocal'" >> ~/.bashrc
    echo "alias mke='eval \\$(minikube docker-env -p k8sLocal)'" >> ~/.bashrc
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  ✅ VM k8sLocal lista para MicroProyecto2                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📂 Tu proyecto está en: /vagrant/microProyecto2_CloudComputing"
    echo ""
    echo "🚀 QUICK START - Para desplegar tu aplicación:"
    echo "   1. vagrant ssh"
    echo "   2. cd /vagrant/microProyecto2_CloudComputing"
    echo "   3. ./quickstart.sh"
    echo "   4. Seleccionar [1] Minikube (Local)"
    echo ""
    echo "🌐 Acceso desde Windows:"
    echo "   • IP VM: 192.168.56.10"
    echo "   • Frontend: http://localhost:8080 (port forwarding)"
    echo "   • Minikube IP: $(minikube ip -p k8sLocal 2>/dev/null || echo 'N/A')"
    echo ""
    echo "📊 Para registrar en Rancher:"
    echo "   • IP pública VM: $(hostname -I | awk '{print $1}')"
    echo "   • Contexto kubectl: k8sLocal"
    echo ""
    echo "� Aliases disponibles:"
    echo "   • k = kubectl"
    echo "   • kgp = kubectl get pods -A"
    echo "   • mk = minikube -p k8sLocal"
    echo "   • mke = eval \\$(minikube docker-env -p k8sLocal)"
    echo ""
    echo "📚 Documentación completa: /vagrant/GUIA_VAGRANT_MICROPROYECTO2.md"
    echo ""
  SHELL
end
