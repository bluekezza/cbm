# -*- coding: utf-8 -*-
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end
  config.vm.box = "saucy32"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/20140122/saucy-server-cloudimg-i386-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "192.168.2.4"
  config.vm.synced_folder "./", "/home/vagrant/cbm"

  config.vm.provision :shell, :inline => <<EOF
    locale-gen en_GB.UTF-8
    apt-get update
EOF
  config.vm.provision :shell, :inline => <<EOF
    apt-get install -y haskell-platform
EOF
  config.vm.provision :shell, :inline => <<EOF
su - vagrant -c '
echo export PATH=\~/.cabal/bin:\$PATH >> ~/.bashrc
source ~/.bashrc
cabal update
cabal install cabal-1.18.1.2 cabal-install-1.18.0.2
'
EOF
  config.vm.provision :shell, :inline => <<EOF
su - vagrant -c '
  cd ~/cbm;
  cabal install elm-0.11 elm-server-0.10.1 --constraint "transformers==0.3.0.0"
'
EOF
end
