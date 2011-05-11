# Generated from a Lead, owned by a Campaign.  Deals represent potential
# "deals" with contacts and track revenue used for marketing reports.
#
class Deal < ActiveRecord::Base
  include E9Rails::ActiveRecord::Initialization

  belongs_to :campaign, :inverse_of => :deal
  belongs_to :tracking_cookie, :inverse_of => :deal
  belongs_to :offer, :inverse_of => :deals

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
      end
    else
      record.errors.add(:status, :invalid, :options => Status::OPTIONS.join(', '))
    end
  end

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
  
    # Typically, new Deals are 'pending', with the assumption that offers
    # explicitly create Deals as 'lead' when they convert.
    def _assign_initialization_defaults
      self.status = Status::Pending
    end

  module Status
    OPTIONS  = %w(lead pending won lost)
    Lead    = OPTIONS[0]
    Pending = OPTIONS[1]
    Won     = OPTIONS[2]
    Lost    = OPTIONS[3]
  end
end
