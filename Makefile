fedora-atomic-virtualbox.box: boot.iso template.json vagrantfile.tpl http/atomic-ks.cfg
	packer build -only virtualbox template.json

boot.iso:
	curl -LO http://rpm-ostree.cloud.fedoraproject.org/project-atomic/install/rawhide/20140708.0/boot.iso

test: test/Vagrantfile fedora-atomic-virtualbox.box
	@vagrant box add -f fedora-atomic fedora-atomic-virtualbox.box
	@cd test; \
	vagrant destroy -f; \
	vagrant up; \

clean:
	rm -f boot.iso
	rm -f fedora-atomic-virtualbox.box
	rm -rf output-*/

.PHONY: test clean
