# Generated from a Lead, owned by a Campaign.  Deals represent potential
# "deals" with contacts and track revenue used for marketing reports.
#
class Deal < ActiveRecord::Base
  include E9Rails::ActiveRecord::Initialization
  include E9Rails::ActiveRecord::Scopes::Times
  include E9Rails::ActiveRecord::InheritableOptions

  self.options_column = false

  belongs_to :campaign, :inverse_of => :deals
  belongs_to :offer, :inverse_of => :deals
  belongs_to :user

  belongs_to :owner, :class_name => 'Contact', :foreign_key => :contact_id
  belongs_to :dated_cost

  has_and_belongs_to_many :contacts

  money_columns :value

  validates :value,      :numericality => true
  validates :campaign,   :presence     => true
  validate do |record|
    if !Status::OPTIONS.include?(record.status)
      record.errors.add(:status, :inclusion, :options => Status::OPTIONS)
    elsif record.status_changed? && record.won? || record.lost? and record.status_was == Status::Lead
      record.errors.add(:status, :illegal_conversion)
    end
  end

  # non-lead validations (deals in the admin)
  validates :name, :presence => true, :unless => lambda {|r| r.lead? }

  # lead only validations
  validates :lead_name,  :presence => true, :if => lambda {|r| r.lead? }
  validates :lead_email, :presence => true, :email => { :allow_blank => true }, :if => lambda {|r| r.lead? }

  # If a lead with a user, get the lead_name and lead_email from the user before validation
  before_validation :get_name_and_email_from_user, :on => :create
  before_validation :update_to_pending_status,     :on => :update
  before_validation :disallow_campaign_change_if_closed, :on => :update

  before_destroy :disallow_destroy_if_closed

  # copy temp options over into info column
  before_create :transform_options_column

  # If a lead with no user, find the user by email or create it, then if mailing_lists
  # were passed, assign the user those mailing lists
  after_create :handle_lead_creation, :if => lambda {|r| r.lead? }

  # denormalize campaign code and offer name columns
  before_save :ensure_denormalized_columns
  before_save :ensure_associated_campaign
  before_save :handle_status_conversion, :if => lambda {|r| r.status_changed? }

  # money column definitions for pseudo attributes (added on the reports scope)
  %w(total_value average_value total_cost average_cost).each do |money_column|
    class_eval("def #{money_column}; (r = read_attribute(:#{money_column})) && Money.new(r) end")
  end

  delegate :name, :to => :owner, :prefix => true, :allow_nil => true

  # mailing_list_ids may be set on Deals when they are being created as leads, this is
  # done via opt-in checkboxes on the form
  attr_accessor :mailing_list_ids

  # 
  # reports is technically a deal scope, but actually returns campaigns
  # and a selection of relevant pseudo columns.
  #
  # NOTE reports probably should be a campaign scope?  It doesn't really seem
  # to matter.  The resultset is neither Deals nor Campaigns, anyway, but
  # a selection of calculated columns aggregated from data from both tables.
  # 
  scope :reports, lambda {
    selects = <<-SQL.gsub(/\s+/, ' ')
      campaigns.type                                 campaign_type,
      campaigns.name                                 campaign_name,
      campaigns.new_visits                           new_visits,
      campaigns.repeat_visits                        repeat_visits,
      deals.closed_at                                closed_at,
      deals.created_at                               created_at,
      campaign_groups.name                           campaign_group,
      SUM(IF(deals.status != 'lead',1,0))            deal_count, 
      COUNT(deals.id)                                lead_count,
      SUM(IF(deals.status='won',1,0))                won_deal_count,
      SUM(IF(deals.status='won',deals.value,0))      total_value, 
      AVG(IF(deals.status='won',deals.value,NULL))   average_value, 
      SUM(dated_costs.cost)                          total_cost,
      SUM(dated_costs.cost) / 
        SUM(IF(deals.status='won',1,0))              average_cost,
      FLOOR(AVG(
        DATEDIFF(
          deals.closed_at,
          deals.created_at)))                       average_elapsed
    SQL

    joins = <<-SQL.gsub(/\s+/, ' ')
      RIGHT JOIN campaigns
        ON deals.campaign_id = campaigns.id

      LEFT JOIN dated_costs 
        ON campaigns.id = dated_costs.costable_id 
        AND dated_costs.costable_type = "Campaign" 

      LEFT JOIN campaign_groups
        ON campaign_groups.id = campaigns.campaign_group_id
    SQL

    select(selects).joins(joins).group('campaigns.id')
  }

  scope :column_op, lambda {|op, column, value, reverse=false|
    conditions = arel_table[column].send(op, value)
    conditions = conditions.not if reverse
    where(conditions)
  }

  scope :column_eq, lambda {|column, value, reverse=false|
    column_op(:eq, column, value, reverse)
  }

  scope :leads,    lambda {|reverse=true| column_eq(:status, Status::Lead, !reverse) }
  scope :pending,  lambda {|reverse=true| column_eq(:status, Status::Pending, !reverse) }
  scope :won,      lambda {|reverse=true| column_eq(:status, Status::Won, !reverse) }
  scope :lost,     lambda {|reverse=true| column_eq(:status, Status::Lost, !reverse) }

  scope :category, lambda {|category| where(:category => category) }
  scope :offer,    lambda {|offer|    where(:offer_id => offer.to_param) }
  scope :owner,    lambda {|owner|    where(:contact_id => owner.to_param) }
  scope :status,   lambda {|status|   where(:status => status) }

  def to_liquid
    Drop.new(self)
  end

  def closed?
    [Status::Won, Status::Lost].include? status
  end

  protected

    def write_options(obj={})
      @custom_options = obj.to_hash
    end

    def read_options
      @custom_options ||= {}
    end

    def method_missing(method_name, *args)
      if method_name =~ /(.*)\?$/ && Status::OPTIONS.member?($1)
        self.status == $1
      else
        super
      end
    end

    # Typically, new Deals are 'pending', with the assumption that offers
    # explicitly create Deals as 'lead' when they convert.
    def _assign_initialization_defaults
      self.status ||= Status::Pending
    end

    # this is for leads
    def transform_options_column
      self.info ||= options.to_hash.map {|k, v| "%s:\n%s\n\n" % [k.to_s.titleize, v] }.join
    end

    def ensure_denormalized_columns
      self.campaign_code ||= campaign.code if campaign.present?
      self.offer_name    ||= offer.name    if offer.present?
    end

    def ensure_associated_campaign
      self.campaign ||= Campaign.default
    end

    def get_name_and_email_from_user
      if lead? && user.present?
        self.lead_email = user.email
        self.lead_name  = user.first_name
      end
    end

    def handle_lead_creation
      # If user is not set explicitly yet a lead_email was passed, set the 
      # user, first by attempting to find it by lead_email, and on that 
      # failing, by creating a new prospect.
      if user.blank?
        self.user = User.find_by_email(lead_email) || create_prospect
        update_attribute(:user_id, user.id)
      end

      # Assign the user's contact to the lead, creating it first if it does 
      # not yet exist
      user.create_contact_if_missing!
      self.contacts << user.contact

      # finally if mailing_list_ids were passed in the creation of this lead
      # pass them along to the user.
      if @mailing_list_ids
        user.mailing_list_ids |= @mailing_list_ids
      end

      begin
        if offer && alert_email = offer.conversion_alert_email.presence
          Rails.logger.debug("Sending Deal Conversion Alert to [#{alert_email}]")
          Offer.conversion_email.send!(alert_email, :offer => offer, :lead => self)
        end
      rescue
        Rails.logger.debug("Deal conversion alert failed: #{$!}")
      end
    end

    def update_to_pending_status
      if self.status == Status::Lead
        self.status = Status::Pending
      end
    end

    def create_prospect
      create_user(
        :email      => lead_email,
        :first_name => lead_name,
        :role       => :prospect
      ) 
    end

    def handle_status_conversion
      case status
      when Status::Lead
        self.converted_at = nil
      when Status::Pending
        self.converted_at = Time.now.utc
        self.closed_at = nil
      when Status::Won, Status::Lost
        self.converted_at ||= Time.now.utc
        self.closed_at = Time.now.utc
      end

      # create cost if applicable, else destroy costs
      if campaign.respond_to?(:set_cost)
        dated_cost.try(:delete)

        if status == Status::Won
          create_dated_cost(:costable => campaign, :date => converted_at.to_date)
        end
      end
    end

    def disallow_destroy_if_closed
      if closed?
        errors.add(:status, :closed_no_destroy)
        return false
      end
    end

    def disallow_campaign_change_if_closed
      if closed? && campaign_id_changed?
        errors.add(:campaign, :closed_no_change)
      end
    end

  class Drop < ::E9::Liquid::Drops::Base
    source_methods :name, :category, :lead_email, :lead_name, :info, :offer,
                   :campaign, :contacts, :owner, :status

    date_methods   :closed_at, :converted_at
  end

  module Status
    OPTIONS  = %w(lead pending won lost)
    Lead    = OPTIONS[0]
    Pending = OPTIONS[1]
    Won     = OPTIONS[2]
    Lost    = OPTIONS[3]
  end
end
