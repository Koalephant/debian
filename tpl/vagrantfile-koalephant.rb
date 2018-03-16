Vagrant.configure('2') do |config|
	config.ssh.shell = 'sh'

	NAME = nil unless defined? NAME
	CPUS = 1 unless defined? CPUS
	MEMORY = 512 unless defined? MEMORY

	[:vmware_workstation, :vmware_fusion].each do |provider|
		config.vm.provider(provider) do |vm|
			vm.whitelist_verified = true
			vm.vmx[:numvcpus] = ::CPUS
			vm.vmx[:memsize] = ::MEMORY
			unless ::NAME.nil?
				vm.vmx[:displayname] = ::NAME
			end
		end
	end

	[:parallels, :virtualbox].each do |provider|
		config.vm.provider provider do |vm|
			vm.cpus = ::CPUS
			vm.memory = ::MEMORY
			unless ::NAME.nil?
				vm.name = ::NAME
			end
		end
	end
end
