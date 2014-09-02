fedora-atomic-virtualbox.box: boot.iso box/template.json box/vagrantfile.tpl \
	box/docker_start_service.rb box/change_host_name.rb box/configure_networks.rb \
	http/atomic-ks.cfg oem/etc-sysconfig-docker oem/docker-tcp.socket
	rm -f fedora-atomic-virtualbox.box
	rm -rf output-*/
	@cd box; \
	packer build -only virtualbox template.json

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
	vagrant suspend

clean:
	rm -f boot.iso
	rm -f fedora-atomic-virtualbox.box
	rm -rf output-*/

.PHONY: test clean
