require Vagrant.source_root.join("plugins/provisioners/docker/cap/redhat/docker_start_service.rb")

module VagrantPlugins
  module DockerProvisioner
    module Cap
      module Redhat
        module DockerStartService
          def self.docker_start_service(machine)
            machine.communicate.sudo("systemctl enable docker")
            machine.communicate.sudo("systemctl start docker")
          end
        end
      end
    end
  end
end
