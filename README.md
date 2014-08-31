# Fedora Atomic Packer for Vagrant Box

Build a Vagrant box with [Fedora Atomic](http://www.projectatomic.io/)

- Based on [Fedora Atomic 20140708.0](http://rpm-ostree.cloud.fedoraproject.org/project-atomic/install/rawhide/20140708.0/)
	- kernel v3.16.0
	- docker v1.0.0
	- systemd 215

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

  config.vm.synced_folder ".", "/home/vagrant/shared", type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

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

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

- [CoreOS](https://coreos.com/) is under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)?
