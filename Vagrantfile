# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "geerlingguy/centos7"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--name", "diaspora"]
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.hostname = "diaspora"

  config.vm.network "forwarded_port", guest: 2112, host: 2112

  # Set the name of the VM. See: http://stackoverflow.com/a/17864388/100134
  config.vm.define :diaspora do |diaspora|
  end

  # Ansible provisioner.
  #config.vm.provision "ansible" do |ansible|
  #  ansible.playbook = "deploy.yml"
  #  ansible.vault_password_file = "vault-passwd.txt"
  #  ansible.extra_vars = {
  #    sitename: "diaspora.dev"
  #  }
  #end
end
