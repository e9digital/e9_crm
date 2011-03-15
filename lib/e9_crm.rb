require 'rails'
require 'e9_rails'
require 'e9_tags'
require 'money'
require 'inherited_resources'
require 'will_paginate'
require 'has_scope'

require 'e9_crm/rails_extensions'

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

  mattr_accessor :user_model
  @@user_model = :user

  mattr_accessor :tracking_controllers
  @@tracking_controllers = []

  def E9Crm.log(message)
    Rails.logger.send(@@log_level, "e9Crm: #{message}") if @@logging
  end

  def E9Crm.init!
    E9Crm.determine_user_model.send(:include, E9Crm::Backend::ActiveRecord)

    E9Crm.tracking_controllers.each do |controller|
      controller.send(:include, E9Crm::TrackingController)
    end
  end

  def E9Crm.determine_user_model
    case @@user_model ||= :user
    when Class; @@user_model
    when String, Symbol; @@user_model.classify.constantize
    end
  rescue
    raise ArgumentError, "E9Crm.user_model must be defined as class in your application"
  end

  class Engine < ::Rails::Engine
    config.e9_crm = E9Crm

    config.to_prepare { E9Crm.init! }
  end
end
