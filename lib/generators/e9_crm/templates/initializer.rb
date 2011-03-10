require 'e9_base'
require 'e9_crm'

User.send :include, E9Crm::Backend::ActiveRecord

# NOTE due to some issues with helpers the controller include is happening
#      after initialize.  This is a quick fix basically.  It may not work
#      in all situations, e.g. if you are including the tracking_controller
#      in a chained module to be included (via ActiveSupport::Concern, for
#      example) you would need to do that outide this block so the include
#      is present when the controller code is loaded.
#
Rails.configuration.after_initialize do
  # add controllers that should track
  [].each {|c| c.send(:include, E9Crm::TrackingController) }
end
