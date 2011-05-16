# Generated from a Lead, owned by a Campaign.  Deals represent potential
# "deals" with contacts and track revenue used for marketing reports.
#
class Deal < ActiveRecord::Base
  include E9Rails::ActiveRecord::Initialization
  include E9Rails::ActiveRecord::Scopes::Times

  belongs_to :campaign, :inverse_of => :deals
  belongs_to :tracking_cookie, :inverse_of => :deals
  belongs_to :offer, :inverse_of => :deals

  money_columns :value
  validates :value, :numericality => true

  %w(total_value average_value total_cost average_cost).each do |money_column|
    class_eval("def #{money_column}; (r = read_attribute(:#{money_column})) && Money.new(r) end")
  end

  scope :reports, lambda {
    select_sql = <<-SELECT.gsub(/\s+/, ' ')
      campaigns.id                            campaign_id,
      campaigns.type                          campaign_type,
      campaigns.name                          campaign_name,
      campaign_groups.name                    campaign_group,
      SUM(IF(deals.status != 'lead',1,0))     deal_count, 
      COUNT(deals.id)                         lead_count,
      SUM(IF(deals.status='won',1,0))         won_deal_count,
      campaigns.new_visits                    new_visits, 
      campaigns.repeat_visits                 repeat_visits, 

      SUM(IF(deals.status='won',value,0))     total_value, 
      AVG(IF(deals.status='won',value,NULL))  average_value, 

      (CASE campaigns.type
        WHEN "SalesCampaign"       
          THEN SUM(campaigns.sales_fee)
        WHEN "AdvertisingCampaign" 
          THEN dated_costs.cost 
        WHEN "AffiliateCampaign"   
          THEN SUM(campaigns.sales_fee + 
                   campaigns.affiliate_fee)
        ELSE 
          0 
        END)                                   total_cost,

      (CASE campaigns.type
        WHEN "SalesCampaign"       
          THEN campaigns.sales_fee
        WHEN "AdvertisingCampaign" 
          THEN dated_costs.cost 
        WHEN "AffiliateCampaign"   
          THEN campaigns.sales_fee + 
                 campaigns.affiliate_fee
        ELSE 
          0 
        END / COUNT(deals.id))                 average_cost,

      FLOOR(AVG(
        DATEDIFF(
          deals.closed_at,
          deals.created_at)))                  average_elapsed

    SELECT

    join_sql = <<-JOINS.gsub(/\s+/, ' ')
      LEFT OUTER JOIN dated_costs 
        ON deals.campaign_id          = dated_costs.costable_id 
        AND dated_costs.costable_type = "Campaign" 

      LEFT OUTER JOIN campaigns 
        ON campaigns.id = deals.campaign_id 

      LEFT OUTER JOIN campaign_groups
        ON campaign_groups.id = campaigns.campaign_group_id
    JOINS

    select(select_sql).joins(join_sql).group(:campaign_id)
  }


  validate do |record|
    return unless record.status_changed?

    case record.status
    when Status::Lead
      if [Status::Won, Status::Lost].member?(record.status_was)
        record.errors.add(:status, :illegal_reversion)
      elsif record.persisted?
        # "revert" isn't happening on new records
        record.send :_do_revert
      end
    when Status::Pending
      if record.status_was == Status::Lead
        record.send :_do_convert
      end
    when Status::Won, Status::Lost
      if record.status_was == Status::Lead
        record.errors.add(:status, :illegal_conversion)
      elsif record.persisted?
        # "close" isn't happening on new records
        record.send :_do_close
      end
    else
      record.errors.add(:status, :invalid, :options => Status::OPTIONS.join(', '))
    end
  end

  scope :column_op, lambda {|op, column, value, reverse=false|
    conditions = arel_table[column].send(op, value)
    conditions = conditions.not if reverse
    where(conditions)
  }

  scope :column_eq, lambda {|column, value, reverse=false|
    column_op(:eq, column, value, reverse)
  }

  scope :leads,   lambda {|reverse=true| column_eq(:status, Status::Lead, !reverse) }
  scope :pending, lambda {|reverse=true| column_eq(:status, Status::Pending, !reverse) }
  scope :won,     lambda {|reverse=true| column_eq(:status, Status::Won, !reverse) }
  scope :lost,    lambda {|reverse=true| column_eq(:status, Status::Lost, !reverse) }


  protected

    def method_missing(method_name, *args)
      if method_name =~ /(.*)\?$/ && Status::OPTIONS.member?($1)
        self.status == $1
      else
        super
      end
    end

    def _do_convert
      self.converted_at = Time.now.utc
      notify_observers :before_convert
    end

    def _do_revert
      self.converted_at = nil
      notify_observers :before_revert
    end

    def _do_close
      self.closed_at = nil
      notify_observers :before_close
    end
  
    # Typically, new Deals are 'pending', with the assumption that offers
    # explicitly create Deals as 'lead' when they convert.
    def _assign_initialization_defaults
      self.status ||= Status::Pending
    end

  module Status
    OPTIONS  = %w(lead pending won lost)
    Lead    = OPTIONS[0]
    Pending = OPTIONS[1]
    Won     = OPTIONS[2]
    Lost    = OPTIONS[3]
  end
end
