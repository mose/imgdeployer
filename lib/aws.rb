require 'aws-sdk-ec2'
# require "ostruct"

module Manager
  class AWS

    attr_writer :instance_id
    attr_reader :res
    
    def initialize(key, secret, instance_id)
      @instance_id = "#{instance_id}"
      @ec2 = Aws::EC2::Client.new(
        access_key_id: key,
        secret_access_key: secret
      )
      @res = Aws::EC2::Resource.new(
        client: @ec2,
        region: 'us-east-1'
      )
    end

    def instance
      @res.instance(@instance_id)
      # OpenStruct.new(public_ip_address: '1.1.1.1', state: OpenStruct.new(code: 2))
    end

    def instance_status
      @ec2.describe_instance_status({
        instance_ids: [ @instance_id ],
        filters: [
          {
            name: 'instance-status.status',
            values: %w{ ok impaired initializing insufficient-data not-applicable }
          }
        ]
      })
    end

    def random
      rand(36**8).to_s(36)
    end

    def create
      if @instance_id and @instance_id != ''
        { error: "An instance is already defined." }
      else
        # puts @res.inspect
        begin
          i = @res.create_instances({
            image_id: 'ami-924468e8', # bitnami-wordpress-4.9.2-0-linux-debian-9-x86_64-hvm-ebs // 2018 jan 17
            min_count: 1,
            max_count: 1,
            instance_type: 't2.micro' # m3.medium recommended for prod
          })
          # puts i.inspect
          i[0].id
        rescue StandardError => error
          { error: error.message }
        end
      end
    end

    def start
      if @instance_id
        case instance.state.code
        when 0  # pending
          { error: "#{id} is pending, so it will be running in a bit" }
        when 16  # started
          { error: "#{id} is already started" }
        when 48  # terminated
          { error: "#{id} is terminated, so you cannot start it" }
        else
          instance.start
          { message: 'Starting in progress' }
        end
      else
        { error: "no instance running" }
      end
    end

    def restart
      if @instance_id
        case instance.state.code
        when 48  # terminated
          { error: "#{id} is terminated, so you cannot reboot it" }
        else
          instance.reboot
          { message: 'Restart in progress' }
        end
      else
        { error: "no instance running" }
      end
    end

    def stop
      if @instance_id
        case instance.state.code
        when 48
          { error: "#{id} is terminated, so you cannot stop it" }
        when 64
          { error: "#{id} is stopping, so it will be stopped in a bit" }
        when 80
          { error: "#{id} is already stopped" }
        else
          instance.stop
          { message: 'Stopping in progress' }
        end
      else
        { error: "no instance running" }
      end
    end

    def terminate
      if @instance_id
        case instance.state.code
        when 48  # terminated
          { error: "#{id} is already terminated" }
        else
          instance.terminate
          { message: 'Termination in progress' }
        end
      else
        { error: "no instance running" }
      end
    end

  end
end
