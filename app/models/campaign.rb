# The base campaign class
#
# A Campaign is created with a unique code, which in turn generates PageViews,
# which maybe become Leads (Offers), which may result in Deals.
#
class Campaign < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI

  belongs_to :campaign_group
  has_many   :deals, :inverse_of => :campaign
  has_many   :page_views, :inverse_of => :campaign

  # NOTE tracking cookie code changes with new visits
  has_many :tracking_cookies, :foreign_key => :code, :primary_key => :code, :class_name => 'TrackingCookie'

  validates :code,          :presence     => true,
                            :length       => { :maximum => 32 }, 
                            :uniqueness   => { :ignore_case => true }
  validates :affiliate_fee, :numericality => true
  validates :sales_fee,     :numericality => true


  scope :active,   lambda {|val=true| where(:active => val) }
  scope :inactive, lambda { active(false) }
  scope :of_group, lambda {|val| where(:campaign_group_id => val.to_param) }

  def new_visit_session_count
    page_views.new_visits.group(:session).count.keys.length
  end

  def new_visit_page_view_count
    page_views.new_visits.group(:session).count.values.sum
  end

  def repeat_visit_session_count
    page_views.repeat_visits.group(:session).count.keys.length
  end

  def repeat_visit_session_count
    page_views.repeat_visits.group(:session).count.values.sum
  end

  ##
  # The sum cost of this campaign
  # (Must be implemented by subclasses)
  #
  def cost
    raise NotImplementedError
  end

  def to_s
    name
  end
end
