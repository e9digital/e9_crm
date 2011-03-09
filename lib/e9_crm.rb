require 'rails'

module E9Crm
  autoload :VERSION,            'e9_crm/version'
  autoload :TrackingController, 'e9_crm/tracking_controller'

  module Backend
    autoload :ActiveRecord,     'e9_crm/backend/active_record'
  end

  mattr_accessor :current_user

  class Engine < ::Rails::Engine
    config.e9_crm = E9Crm
  end
end
