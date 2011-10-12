require 'e9_base'
require 'money'
require 'e9_crm/rails_extensions'

module E9Crm
  autoload :VERSION,                    'e9_crm/version'
  autoload :Controller,                 'e9_crm/controller'
  autoload :Model,                      'e9_crm/model'
  autoload :TrackingController,         'e9_crm/tracking_controller'
  autoload :SystemEmailsController,     'e9_crm/system_emails_controller'

  module Rack
    autoload :ContactAutoCompleter,       'e9_crm/rack/contact_auto_completer'
    autoload :CompanyAutoCompleter,       'e9_crm/rack/company_auto_completer'
    autoload :EmailCampaignAutoCompleter, 'e9_crm/rack/email_campaign_auto_completer'
    autoload :EmailAvailabilityChecker,   'e9_crm/rack/email_availability_checker'
  end

  mattr_accessor :cookie_name
  @@cookie_name = '_e9_tc'

  mattr_accessor :query_param
  @@query_param = 'code'

  mattr_accessor :query_user_id
  @@query_user_id = 'cuid'

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

    ::Admin::SystemEmailsController.send(:include, E9Crm::SystemEmailsController)

    E9Crm.tracking_controllers.each do |controller|
      controller.send(:include, E9Crm::TrackingController)
    end

    MenuOption.keys |= %w(Deal\ Category)
  end

  class Engine < ::Rails::Engine
    config.e9_crm = E9Crm
    config.active_record.observers ||= []
    config.active_record.observers << :deal_observer
    config.to_prepare { E9Crm.init! }
  end
end
