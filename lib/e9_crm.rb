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
  autoload :Controller,         'e9_crm/controller'
  autoload :Model,              'e9_crm/model'
  autoload :TrackingController, 'e9_crm/tracking_controller'

  mattr_accessor :cookie_name
  @@cookie_name = '_e9_tc'

  mattr_accessor :query_param
  @@query_param = 'code'

  mattr_accessor :log_level
  @@log_level = :debug

  mattr_accessor :logging
  @@logging = false

  mattr_accessor :user_model
  @@user_model = nil

  mattr_accessor :tracking_controllers
  @@tracking_controllers = []

  def E9Crm.log(message)
    Rails.logger.send(@@log_level, "e9Crm: #{message}") if @@logging
  end

  def E9Crm.configure
    yield self
  end

  def E9Crm.init!
    user_model = case @@user_model
    when Class; @@user_model
    when String, Symbol; @@user_model.classify.constantize
    end

    if user_model
      user_model.send(:include, E9Crm::Model)
    end

    ActionController::Base.send(:include, E9Crm::Controller)

    E9Crm.tracking_controllers.each do |controller|
      controller.send(:include, E9Crm::TrackingController)
    end
  end

  class Engine < ::Rails::Engine
    config.e9_crm = E9Crm
    config.active_record.observers ||= []
    config.active_record.observers << :deal_observer
    config.to_prepare { E9Crm.init! }
  end
end
