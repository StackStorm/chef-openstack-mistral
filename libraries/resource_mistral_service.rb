require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MistralService < Chef::Resource::LWRPBase
      self.resource_name = :mistral_service
      actions :create, :delete, :start, :stop, :restart
      default_action :create

      attribute :bind_address, kind_of: String, default: '0.0.0.0'
      attribute :port, kind_of: String, default: 8989
      attribute :run_group, kind_of: String, default: 'mistral'
      attribute :run_user, kind_of: String, default:  'mistral'
      attribute :conf_source, kind_of: String, default: 'mistral.conf.erb'
      attribute :log_source, kind_of: String, default: 'logging.conf.erb'
      attribute :conf_cookbook, kind_of: String, default: nil
      attribute :log_cookbook, kind_of: String, default: nil
      attribute :options, kind_of: [Hash], default: nil
      attribute :log_variables, kind_of: [Hash], default: nil
      attribute :touch_logfiles, kind_of: [Array], default: []
      attribute :starts, kind_of: [Symbol, String, Array], callbacks: {
        'should be combination of :api, :engine, :executor' => lambda {|value| validate_starts(value)}
      }

      def self.validate_starts(value)
        supports = [ :api, :engine, :executor ]
        values = Array(value).map { |v| v.to_sym }
        not values.any? { |v| !supports.include?(v) }
      end

    end
  end
end
