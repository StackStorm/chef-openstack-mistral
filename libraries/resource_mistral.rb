require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class Mistral < Chef::Resource::LWRPBase

      self.resource_name = :mistral
      actions :create, :delete, :start, :stop, :restart
      default_action :create

      attribute :service_name, kind_of: String, name_attribute: true
      attribute :bind_address, kind_of: String, default: '0.0.0.0'
      attribute :port, kind_of: Integer, default: 8989
      attribute :run_group, kind_of: String, default: 'mistral'
      attribute :run_user, kind_of: String, default:  'mistral'
      attribute :options, kind_of: [ Hash ], default: nil
      attribute :logfile_source, kind_of: String, default: nil
      attribute :logfile_options, kind_of: [ Hash ], default: nil
      attribute :logfile_creates, kind_of: [ Array ], default: [ '/var/log/mistral.log' ]
      attribute :starts, kind_of: [ Symbol, String, Array ], callbacks: {
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
