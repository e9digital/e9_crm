class Campaign < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI

  belongs_to :campaign_group
  has_many   :page_views,       :foreign_key => :code, :primary_key => :code
  has_many   :tracking_cookies, :foreign_key => :code, :primary_key => :code, :class_name => 'TrackingCookie'

  validates  :code, :length     => { :maximum => 32 }, 
                    :uniqueness => { :ignore_case => true }

  def cost
    Money.new(100)
  end

  module Status
    VALUES   = %w(inactive active)
    INACTIVE = 0
    ACTIVE   = 1
  end
end
