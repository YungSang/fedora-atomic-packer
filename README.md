# Fedora Atomic Packer for Vagrant Box

Build a Vagrant box with [Fedora Atomic](http://www.projectatomic.io/)

- Based on [Fedora Atomic 2014-12-13 11:14:55 (bea2d675ea)](http://download.fedoraproject.org/pub/fedora/linux/atomic/rawhide/refs/heads/fedora-atomic/rawhide/x86_64/)
 	- fedora-release-22-0.10.noarch
	- kernel-3.18.0-1.fc22.x86_64
	- grub2-1:2.02-0.13.fc22.x86_64
	- dbus-1:1.8.12-2.fc22.x86_64
	- systemd-218-1.fc22.x86_64
	- NetworkManager-1:0.9.10.0-14.git20140704.fc22.x86_64
	- device-mapper-1.02.92-3.fc22.x86_64
	- ostree-2014.12-1.fc22.x86_64
	- rpm-ostree-2014.113-1.fc22.x86_64
	- bash-4.3.30-2.fc22.x86_64
	- openssl-1:1.0.1j-3.fc22.x86_64
	- nfs-utils-1:1.3.1-2.3.fc22.x86_64
	- cloud-init-0.7.6-2.fc22.x86_64
	- **docker-io-1.4.0-2.fc22.x86_64**
	- cadvisor-0.6.2-0.0.git89088df.fc22.x86_64
	- **cockpit-0.34-1.fc22.x86_64**
	- etcd-0.4.6-7.fc22.x86_64 (etcdctl is missing.)
	- kubernetes-0.6-4.0.git993ef88.fc22.x86_64
	- <del>git-2.1.0-5.fc22.x86_64</del>
	- flannel-0.1.0-8.gita7b435a.fc22.x86_64
- Expose the official IANA registered Docker port 2375
- Upgradable: `sudo atomic upgrade`
- Adopt [toolbox](https://github.com/YungSang/toolbox/tree/fedora-atomic) from CoreOS to use systemd-nspawn easily
- Support NFS synced folder
- **413MB**

## How to Build

```
$ make
```

## How to Use

```
$ vagrant box add fedora-atomic fedora-atomic-virtualbox.box
$ vagrant init fedora-atomic -m
$ vagrant up
```

Or

```
$ vagrant init yungsang/fedora-atomic -m
$ vagrant up
```

## Sample Vagrantfile

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "fedora-atomic"

  config.vm.hostname = "fedora-atomic"

  config.vm.box = "yungsang/fedora-atomic"

  config.vm.network :forwarded_port, guest: 2375, host: 2375

  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.synced_folder ".", "/opt/vagrant", type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

  config.vm.provision :docker do |d|
    d.pull_images "yungsang/busybox"
    d.run "simple-echo",
      image: "yungsang/busybox",
      args: "-p 8080:8080",
      cmd: "nc -p 8080 -l -l -e echo hello world!"
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
end
```

## Toolbox

```
[vagrant@fedora-atomic ~]$ toolbox
Pulling repository fedora
88b42ffd1f7c: Download complete
511136ea3c5a: Download complete
c69cab00d6ef: Download complete
vagrant-fedora-latest
Spawning container vagrant-fedora-latest on /var/lib/toolbox/vagrant-fedora-latest.
Press ^] three times within 1s to kill container.
[root@fedora-atomic ~]# 
```

## Docker exec

```
[vagrant@fedora-atomic ~]$ sudo docker ps
CONTAINER ID        IMAGE                     COMMAND                CREATED             STATUS              PORTS                    NAMES
f88a6962f536        yungsang/busybox:latest   "nc -p 8080 -l -l -e   7 minutes ago       Up 7 minutes        0.0.0.0:8080->8080/tcp   simple-echo
[vagrant@fedora-atomic ~]$ sudo docker exec -it f88a6962f536 sh
/ # 
```

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
