# The base campaign class
#
# A Campaign is created with a unique code, which in turn generates PageViews,
# which maybe become Leads (Offers), which may result in Deals.
#
class Campaign < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI

  belongs_to :campaign_group

  has_many   :deals, :inverse_of => :campaign, :dependent => :nullify
  has_many   :won_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Won]
  has_many   :lost_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Lost]
  has_many   :pending_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Pending]
  has_many   :leads, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Lead]

  has_many   :page_views, :inverse_of => :campaign, :dependent => :nullify

  # only advertising campaigns use this association
  has_many :dated_costs, :as => :costable

  # NOTE tracking cookie code changes with new visits
  has_many :tracking_cookies, :foreign_key => :code, :primary_key => :code, :class_name => 'TrackingCookie'

  def self.default
    NoCampaign.first || NoCampaign.create
  end

  validates :name,          :presence     => true,
                            :uniqueness   => { :allow_blank => true, :case_sensitive => false }

  validates :code,          :presence     => { :unless => lambda {|r| r.is_a?(NoCampaign) } },
                            :length       => { :maximum => 32 },
                            :format       => { :allow_blank => true, :with => /^[\w\d]+$/ },
                            :uniqueness   => { :case_sensitive => false, :allow_blank => true }

  validates :affiliate_fee, :numericality => true
  validates :sales_fee,     :numericality => true

  scope :active,   lambda {|val=true| where(:active => val) }
  scope :inactive, lambda { active(false) }
  scope :of_group, lambda {|val| where(:campaign_group_id => val.to_param) }
  scope :typed,    lambda { where(arel_table[:type].not_eq('NoCampaign')) }

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
