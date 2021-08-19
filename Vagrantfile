Vagrant.configure("2") do |config|
    servers=[
        {
          :hostname => "MasterServer",
          :box => "centos/7",
          :ip => "172.16.1.50",
		  :guestport => "80",
		  :hostport => "80",
		  :script => "master.sh"
        },
		{
          :hostname => "SlaveServer",
          :box => "centos/7",
          :ip => "172.16.1.51",
		  :guestport => "8080",
		  :hostport => "1234",
		  :script => "slave.sh"
        },
		{
          :hostname => "DeployServer",
          :box => "centos/7",
          :ip => "172.16.1.52",
		  :guestport => "8080",
		  :hostport => "1235",
		  :script => "deploy.sh"
        }
      ]

    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = machine[:box]
            node.vm.hostname = machine[:hostname]
            node.vm.network :private_network, ip: machine[:ip]
            node.vm.network "forwarded_port", guest: machine[:guestport], host: machine[:hostport]
			node.vm.provision :shell, path: machine[:script]

            node.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm", :id, "--memory", 1024]
                vb.customize ["modifyvm", :id, "--cpus", 2]
            end
        end
    end
end