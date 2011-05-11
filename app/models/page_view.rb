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

  scope :by_user, lambda {|*users| 
    users.flatten!
    users.map! &:to_param
    joins(:tracking_cookie).where(TrackingCookie.arel_table[:user_id].send *(users.length == 1 ? [:eq, users.pop] : [:in, users]))
  }

  scope :by_campaign, lambda {|*campaigns| 
    campaigns.flatten!
    campaigns.map! &:to_param
    where(arel_table[:campaign_id].send *(campaigns.length == 1 ? [:eq, campaigns.pop] : [:in, campaigns]))
  }

end
