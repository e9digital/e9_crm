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
  belongs_to :tracking_cookie
  has_one :user, :through => :tracking_cookie
  has_one :campaign, :inverse_of => :page_views

  scope :new_visits,    lambda { |v=true| where(:new_visit => v) }
  scope :repeat_visits, lambda { new_visits(false) }
end
