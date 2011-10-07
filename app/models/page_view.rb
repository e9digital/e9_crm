# A visit to the site
# 
# Page views belong to a tracking cookie, from which it derives its
# campaign code, and whether or not it is a "new visit" for the given
# campaign code.
#
# === Also stored from the request:
#
# [request_path] The full request path
# [user_agent]   The request user agent
# [referer]      The request referer if it exists
# [remote_ip]    The originating ip address of the request
# [session]      The session id of the request
#
class PageView < ActiveRecord::Base
  include E9Rails::ActiveRecord::Scopes::Times
  include E9::ActiveRecord::TimeScopes

  belongs_to :tracking_cookie

  belongs_to :campaign, :inverse_of => :page_views
  has_one :user, :through => :tracking_cookie

  scope :by_users, lambda {|*users| 
    joins(:tracking_cookie) & TrackingCookie.for_users(users)
  }

  scope :new_visits,    lambda {|v=true| where(:new_visit => v) }
  scope :repeat_visits, lambda { new_visits(false) }

  delegate :name, :code, :to => :campaign, :prefix => true, :allow_nil => true
  delegate :contact, :to => :user, :allow_nil => true
end
