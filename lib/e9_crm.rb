require 'rails'

module E9Crm
  autoload :VERSION,            'e9_crm/version'
  autoload :TrackingController, 'e9_crm/tracking_controller'

  module Backend
    autoload :ActiveRecord,     'e9_crm/backend/active_record'
  end

  mattr_accessor :cookie_name
  @@cookie_name = '_e9_tc'

  mattr_accessor :query_param
  @@query_param = 'code'

  mattr_accessor :log_level
  @@log_level = :debug

  mattr_accessor :logging
  @@logging = true

  def E9Crm.log(message)
    Rails.logger.send(@@log_level, "e9Crm: #{message}") if @@logging
  end

  class Engine < ::Rails::Engine
    config.e9_crm = E9Crm
  end
end
