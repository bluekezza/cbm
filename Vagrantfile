# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "192.168.2.3"
  config.vm.synced_folder "./", "/home/vagrant/workspace"

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "apt"

  config.vm.provision :shell, :inline => <<EOF
    apt-get install -y squid-deb-proxy-client
    sed -i.bak 's/us\.archive\.ubuntu\.com/gb.archive.ubuntu.com/' /etc/apt/sources.list
    apt-get update
    apt-get install -y haskell-platform
    cabal update
    cabal install Cabal
    cabal install cabal-install
    echo "export PATH=~/.cabal/bin:$PATH" >> /home/vagrant/.profile
su - vagrant -c "
cd /home/vagrant/workspace;
export PATH=/home/vagrant/.cabal/bin:$PATH
#cabal sandbox init;
#export PATH=./.cabal-sandbox/bin:$PATH;
cabal update
cabal install pandoc --reinstall --force-reinstalls --constraint=transformers==0.3.0.0 --max-backjumps=10000;
cabal install elm;
cabal install elm-server;
"
EOF
  end
end
