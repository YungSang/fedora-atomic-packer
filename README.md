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

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

- [CoreOS](https://coreos.com/) is under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)?
