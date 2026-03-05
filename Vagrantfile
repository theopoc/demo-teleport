# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"

  # Configuration par défaut pour toutes les VMs (VirtualBox provider)
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = 4096
  end

  # ==========================================================================
  # VM 1: Teleport Bastion
  # ==========================================================================
  config.vm.define "teleport-bastion", primary: true do |bastion|
    bastion.vm.hostname = "teleport-bastion"
    # Réseau privé avec IP statique (accessible depuis le host)
    bastion.vm.network "private_network", ip: "192.168.56.10"
    # Port forwarding pour SSH (optionnel, déjà sur 2222)
    # bastion.vm.network "forwarded_port", guest: 3080, host: 3080
    # bastion.vm.network "forwarded_port", guest: 3025, host: 3025
    # bastion.vm.network "forwarded_port", guest: 3024, host: 3024

    bastion.vm.provider "virtualbox" do |vb|
      vb.name = "teleport-bastion"
    end

    bastion.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/bastion.yml"
      ansible.inventory_path = "ansible/inventory/hosts.yml"
      ansible.verbose = "v"
    end

  end

  # ==========================================================================
  # VM 2: Target Server (Nginx + MySQL + Teleport Agent)
  # ==========================================================================
  config.vm.define "target-server" do |target|
    target.vm.hostname = "target-server"
    # Réseau privé avec IP statique (accessible depuis le host)
    target.vm.network "private_network", ip: "192.168.56.11"
    # Port forwarding pour accès direct
    # target.vm.network "forwarded_port", guest: 80, host: 8080
    # target.vm.network "forwarded_port", guest: 3306, host: 3306

    target.vm.provider "virtualbox" do |vb|
      vb.name = "target-server"
    end

    target.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/target.yml"
      ansible.inventory_path = "ansible/inventory/hosts.yml"
      ansible.verbose = "v"
    end

  end
end
