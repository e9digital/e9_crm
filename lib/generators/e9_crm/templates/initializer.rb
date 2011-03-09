require 'e9_base'
require 'e9_crm'

User.send :include, E9Crm::Backend::ActiveRecord

Rails.configuration.after_initialize do
  # add controllers that should track
  [].each {|c| c.send(:include, E9Crm::TrackingController) }
end
