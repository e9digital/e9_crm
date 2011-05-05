# The base campaign class
#
# A Campaign is created with a unique code, which in turn generates PageViews,
# which maybe become Leads (Offers), which may result in Deals.
#
class Campaign < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI

  belongs_to :campaign_group
  has_many   :deals
  #has_many   :leads
  has_many   :page_views,       :foreign_key => :code, :primary_key => :code
  has_many   :tracking_cookies, :foreign_key => :code, :primary_key => :code, :class_name => 'TrackingCookie'

  validates  :code, :presence   => true
                    :length     => { :maximum => 32 }, 
                    :uniqueness => { :ignore_case => true }

  ##
  # The sum cost of this campaign
  # (Must be implemented by subclasses)
  #
  def cost
    raise NotImplementedError
  end

  module Status
    VALUES   = %w(inactive active)
    INACTIVE = 0
    ACTIVE   = 1
  end
end
