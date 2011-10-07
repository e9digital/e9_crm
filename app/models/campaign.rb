# The base campaign class
#
# A Campaign is created with a unique code, which in turn generates PageViews,
# which maybe become Leads (Offers), which may result in Deals.
#
class Campaign < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI
  include E9::ActiveRecord::AttributeSearchable

  belongs_to :campaign_group

  has_many :deals, :inverse_of => :campaign, :dependent => :nullify
  has_many :won_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Won]
  has_many :lost_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Lost]
  has_many :pending_deals, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Pending]
  has_many :leads, :class_name => 'Deal', :conditions => ['deals.status = ?', Deal::Status::Lead]
  has_many :non_leads, :class_name => 'Deal', :conditions => ['deals.status != ?', Deal::Status::Lead]

  has_many :page_views, :inverse_of => :campaign, :dependent => :nullify
  has_many :new_page_views, :class_name => 'PageView', :conditions => ['page_views.new_visit = ?', true]
  has_many :repeat_page_views, :class_name => 'PageView', :conditions => ['page_views.new_visit = ?', false]

  # only advertising campaigns use this association
  has_many :dated_costs, :as => :costable

  # NOTE tracking cookie code changes with new visits
  has_many :tracking_cookies, :foreign_key => :code, :primary_key => :code, :class_name => 'TrackingCookie'

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
  scope :of_group, lambda {|val| joins(:campaign_group).where(:campaign_group_id => val.to_param) }
  scope :typed,    lambda { where(arel_table[:type].not_eq('NoCampaign')) }
  scope :ordered,  lambda { order(arel_table[:name].asc) }

  scope :reports, lambda {|*args|
    options = args.extract_options!

    selects = <<-SQL.gsub(/\s+/, ' ')
      campaigns.*,

      SUM(IF(deals.status != 'lead',1,0))               deal_count, 

      COUNT(deals.id)                                   lead_count,

      SUM(IF(deals.status='won',1,0))               won_deal_count,
      SUM(IF(deals.status IN('won','lost'),1,0)) closed_deal_count,
      SUM(IF(deals.status='won',deals.value,0))        total_value, 
      AVG(IF(deals.status='won',deals.value,NULL))   average_value, 
      
      SUM(costs.total)                                  total_cost,
      SUM(costs.total) / 
        SUM(IF(deals.status='won',1,0))               average_cost,

      IFNULL(rv.count, 0)                            repeat_visits,
      IFNULL(nv.count, 0)                               new_visits,

      SUM(DATEDIFF(
        deals.closed_at,
        deals.created_at))                           total_elapsed,

      AVG(DATEDIFF(
        deals.closed_at,
        deals.created_at))                         average_elapsed
    SQL

    select(selects).
      joins(
        'LEFT OUTER JOIN deals ' +
        'ON deals.campaign_id = campaigns.id ' +
        "#{ 'AND ' + Deal.for_time_range_conditions(*args, options).to_sql if args.present?}").
      joins(
        'LEFT OUTER JOIN ( ' +
         'SELECT SUM(cost) total, costable_id dc_cid ' +
         'FROM dated_costs ' +
         'WHERE costable_type="Campaign" ' +
         "#{ 'AND ' + DatedCost.for_time_range_conditions(*args, options).to_sql if args.present?}" +
         ' GROUP BY dc_cid) costs ' +
         'ON costs.dc_cid = campaigns.id').
      joins(
        'LEFT OUTER JOIN ( ' +
        'SELECT COUNT(DISTINCT session) count, campaign_id nv_cid ' +
        'FROM page_views ' +
        'WHERE page_views.new_visit = 1 ' +
        "#{ 'AND ' + PageView.for_time_range_conditions(*args, options).to_sql if args.present?}" +
        ' GROUP BY nv_cid ) nv ' + 
        'ON nv.nv_cid = campaigns.id').
      joins(
        'LEFT OUTER JOIN ( ' +
        'SELECT COUNT(DISTINCT session) count, campaign_id rv_cid ' +
        'FROM page_views ' +
        'WHERE page_views.new_visit = 0 ' +
        "#{ 'AND ' + PageView.for_time_range_conditions(*args, options).to_sql if args.present?}" +
        ' GROUP BY rv_cid ) rv ' +
        'ON rv.rv_cid = campaigns.id').
      group('campaigns.id')
  }

  def self.default
    NoCampaign.first || NoCampaign.create
  end

  # money column definitions for pseudo attributes (added on the reports scope)
  %w(total_value average_value total_cost average_cost).each do |money_column|
    class_eval("def #{money_column}; (r = read_attribute(:#{money_column})) && Money.new(r) end")
  end

  def new_visit_count
    new_visits.group(:session).count.keys.length
  end

  def new_visit_page_view_count
    new_visits.group(:session).count.values.sum
  end

  def repeat_visit_count
    repeat_visits.group(:session).count.keys.length
  end

  def repeat_visit_page_view_count
    repeat_visits.group(:session).count.values.sum
  end

  ##
  # The sum cost of this campaign
  # (Must be implemented by subclasses)
  #
  def cost
    raise NotImplementedError
  end

  def to_s
    name.dup.tap {|n| n << " (#{code})" if code.present? }
  end

  def to_liquid
    Drop.new(self)
  end

  class Drop < ::E9::Liquid::Drops::Base
    source_methods :name, :code
  end
end
