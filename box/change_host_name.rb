require Vagrant.source_root.join("plugins/guests/fedora/cap/change_host_name.rb")

module VagrantPlugins
  module GuestFedora
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          machine.communicate.tap do |comm|
            comm.sudo("hostnamectl set-hostname #{name}")
          end
        end
      end
    end
  end
end

require Vagrant.source_root.join("plugins/guests/redhat/cap/change_host_name.rb")

module VagrantPlugins
  module GuestRedHat
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          machine.communicate.tap do |comm|
            comm.sudo("hostnamectl set-hostname #{name}")
          end
        end
      end
    end
  end
end
