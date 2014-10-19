VM_NAME  := Fedora Atomic Packer
BOX_NAME := Fedora Atomic Box

PWD := `pwd`

virtualbox: fedora-atomic-virtualbox.box

parallels: fedora-atomic-parallels.box

fedora-atomic-virtualbox.box: boot.iso box/template.json box/vagrantfile.tpl \
	box/docker_start_service.rb box/change_host_name.rb box/configure_networks.rb \
	box/network_static.erb \
	http/atomic-ks.cfg oem/etc-sysconfig-docker oem/docker-tcp.socket oem/oem-release
	rm -f fedora-atomic-virtualbox.box
	rm -rf box/output-virtualbox/
	@cd box; \
	packer build -only virtualbox template.json

fedora-atomic-parallels.box: fedora-atomic-virtualbox.box Vagrantfile
	rm -f fedora-atomic-parallels.box
	mkdir -p parallels
	@cd parallels; \
	rm -rf *; \
	tar zxvf ../fedora-atomic-virtualbox.box; \
	rm -f box.ovf fedora-atomic-disk1.vmdk; \
	echo '{"provider": "parallels"}' > metadata.json
	#
	# Convert VMDK to HDD
	#
	@vagrant box add -f fedora-atomic fedora-atomic-virtualbox.box
	vagrant destroy -f
	VM_NAME="${VM_NAME}" vagrant up
	vagrant halt -f
	rm -rf "${HOME}/Documents/Parallels/fedora-atomic-disk1.hdd"
	-prl_convert "${HOME}/VirtualBox VMs/${VM_NAME}/fedora-atomic-disk1.vmdk" --allow-no-os
	vagrant destroy -f
	#
	# Create Parallels VM
	#
	prlctl create "${VM_NAME}" --ostype linux --distribution fedora-core --no-hdd
	mv "${HOME}/Documents/Parallels/fedora-atomic-disk1.hdd" "${HOME}/Documents/Parallels/${VM_NAME}.pvm/"
	prlctl set "${VM_NAME}" --device-add hdd --image "${HOME}/Documents/Parallels/${VM_NAME}.pvm/fedora-atomic-disk1.hdd"
	prlctl set "${VM_NAME}" --device-bootorder "hdd0 cdrom0"
	#
	# Clone
	#
	-prlctl unregister "${BOX_NAME}"
	rm -rf "Parallels/${BOX_NAME}.pvm"
	prlctl clone "${VM_NAME}" --name "${BOX_NAME}" --template --dst "${PWD}/parallels"
	prlctl unregister "${VM_NAME}"
	rm -rf "${HOME}/Documents/Parallels/${VM_NAME}.pvm"
	#
	# Clean up
	#
	rm -f "parallels/${BOX_NAME}.pvm/config.pvs.backup"
	rm -f "parallels/${BOX_NAME}.pvm/fedora-atomic-disk1.hdd/DiskDescriptor.xml.Backup"
	#
	# Package
	#
	rm -f fedora-atomic-parallels.box
	cd parallels; tar zcvf ../fedora-atomic-parallels.box *
	prlctl unregister "${BOX_NAME}"

boot.iso:
	curl -LO http://rpm-ostree.cloud.fedoraproject.org/project-atomic/install/rawhide/20140708.0/boot.iso

test: test/Vagrantfile fedora-atomic-virtualbox.box
	@vagrant box add -f fedora-atomic fedora-atomic-virtualbox.box
	@cd test; \
	vagrant destroy -f; \
	vagrant up; \
	echo "-----> /etc/os-release"; \
	vagrant ssh -c "cat /etc/os-release"; \
	echo "-----> /etc/redhat-release"; \
	vagrant ssh -c "cat /etc/redhat-release"; \
	echo "-----> /etc/oem-release"; \
	vagrant ssh -c "cat /etc/oem-release"; \
	echo "-----> /etc/machine-id"; \
	vagrant ssh -c "cat /etc/machine-id"; \
	echo "-----> /etc/hostname"; \
	vagrant ssh -c "cat /etc/hostname"; \
	echo "-----> docker version"; \
	DOCKER_HOST="tcp://localhost:2375"; \
	docker version; \
	echo "-----> docker images -t"; \
	docker images -t; \
	echo "-----> docker ps -a"; \
	docker ps -a; \
	echo "-----> nc localhost 8080"; \
	nc localhost 8080; \
	echo "-----> atomic status"; \
	vagrant ssh -c "atomic status"; \
	echo "-----> atomic upgrade"; \
	vagrant ssh -c "sudo atomic upgrade"; \
	echo '-----> docker-enter `sudo docker ps -l -q` ls -l'; \
	vagrant ssh -c 'docker-enter `sudo docker ps -l -q` ls -l'; \
	vagrant suspend

ptest: DOCKER_HOST_IP=$(shell cd test; vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp")
ptest: ptestup
	@cd test; \
	echo "-----> /etc/os-release"; \
	vagrant ssh -c "cat /etc/os-release"; \
	echo "-----> /etc/redhat-release"; \
	vagrant ssh -c "cat /etc/redhat-release"; \
	echo "-----> /etc/oem-release"; \
	vagrant ssh -c "cat /etc/oem-release"; \
	echo "-----> /etc/machine-id"; \
	vagrant ssh -c "cat /etc/machine-id"; \
	echo "-----> /etc/hostname"; \
	vagrant ssh -c "cat /etc/hostname"; \
	echo "-----> docker version"; \
	DOCKER_HOST="tcp://${DOCKER_HOST_IP}:2375"; \
	docker version; \
	echo "-----> docker images -t"; \
	docker images -t; \
	echo "-----> docker ps -a"; \
	docker ps -a; \
	echo "-----> nc ${DOCKER_HOST_IP} 8080"; \
	nc ${DOCKER_HOST_IP} 8080; \
	echo "-----> atomic status"; \
	vagrant ssh -c "atomic status"; \
	echo "-----> atomic upgrade"; \
	vagrant ssh -c "sudo atomic upgrade"; \
	echo '-----> docker-enter `sudo docker ps -l -q` ls -l'; \
	vagrant ssh -c 'docker-enter `sudo docker ps -l -q` ls -l'; \
	vagrant suspend

ptestup: test/Vagrantfile fedora-atomic-parallels.box
	@vagrant box add -f fedora-atomic fedora-atomic-parallels.box
	@cd test; \
	vagrant destroy -f; \
	vagrant up --provider parallels

upgrade: upgrade/Vagrantfile \
	box/docker_start_service.rb box/change_host_name.rb box/configure_networks.rb \
	box/network_static.erb oem/oem-release
	mkdir -p upgrade
	cd upgrade; \
		vagrant destroy -f; \
		vagrant up; \
		vagrant reload; \
		vagrant ssh -c 'sudo ostree admin undeploy 1'; \
		vagrant ssh -c 'sudo ostree admin cleanup'; \
		vagrant ssh -c 'sudo rm -f /etc/machine-id'; \
		vagrant ssh -c 'dd if=/dev/zero of=EMPTY bs=1M || :; rm EMPTY'; \
		vagrant halt -f;
	cd box; \
		rm -f ../fedora-atomic-virtualbox.box; \
		vagrant package --base "Fedora Atomic Upgrade" --output ../fedora-atomic-virtualbox.box --include docker_start_service.rb,change_host_name.rb,configure_networks.rb,network_static.erb --vagrantfile vagrantfile.tpl

clean:
	vagrant destroy -f
	cd test; vagrant destroy -f
	cd upgrade; vagrant destroy -f
	rm -f fedora-atomic-virtualbox.box
	rm -rf box/output-*/
	rm -f fedora-atomic-parallels.box
	rm -rf parallels/

.PHONY: test clean upgrade
