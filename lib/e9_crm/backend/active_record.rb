module E9Crm::Backend
  module ActiveRecord
    def self.included(base)
      base.class_eval do
        has_many :tracking_cookies, :class_name => 'TrackingCookie'
      end
    end
  end
end
