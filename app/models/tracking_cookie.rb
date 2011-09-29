require 'digest/md5'

# Mirrors a browser cookie installed on the client
#
# == Purpose
#
# A +User+ may have many cookies, and it is through these cookies that associated
# +PageView+ records are tracked.
#
# == Behavior
#
# The cookie is tracked through it's hashed id (hid), and maintains the most 
# recent campaign code passed from the associated client.
#
# Immediately after the cookie is loaded or created, a +PageView+ is generated.
# It is given the current +code+ of the cookie, if it exists, and if either the 
# cookie itself is new, or the code on it is new (has changed), that +PageView+ 
# is marked as a new visit.
#
# In this way, a +PageView+ will be credited to a campaign code even if it a
# code is not passed in its actual request.  The timeline might look like this:
#
# 1. A client visits the site normally with no campaign code.
#   - A cookie is created/installed
#   - A new visit, uncoded page view is created
#
# 2. The client visits another page.
#   - The installed cookie is loaded
#   - An uncoded page view is created.
#
# 3. The same client (pre-existing cookie) visits the site with code ABC.
#   - The installed cookie is loaded, its code updated to ABC.
#   - A new visit, ABC coded page view is created
#
# 4. The client visits another page.
#   - The installed cookie is loaded
#   - An ABC coded page view is created
#
# In this manner, page views are always credited to the most recently loaded
# code, with the assumption that it was the most recently seen code that
# prompted the client to (re)visit the site.
#
class TrackingCookie < ActiveRecord::Base
  belongs_to :user, :inverse_of => :tracking_cookies
  has_many :page_views
  after_save :generate_hid, :on => :create

  scope :for_users, lambda {|*users| 
    users.flatten!
    users.map!(&:to_param)
    users.compact!

    if users.length == 1
      where arel_table[:user_id].eq(users.first)
    else
      where arel_table[:user_id].in(users)
    end
  }

  scope :for_user, lambda {|user|
    where arel_table[:user_id].in(users.flatten.map(&:to_param))
  }

  protected

  def generate_hid
    unless hid.present?
      update_attribute :hid, Digest::MD5.hexdigest("#{id}//#{DateTime.now}")
    end
  end
end
