# Generated from a Lead, owned by a Campaign.  Deals represent potential
# "deals" with contacts and track revenue used for marketing reports.
#
class Deal < ActiveRecord::Base
  include E9Rails::ActiveRecord::Initialization

  belongs_to :campaign, :inverse_of => :deal

  belongs_to :tracking_cookie, :inverse_of => :deal
  belongs_to :lead, :inverse_of => :deals

  scope :pending, lambda { where(:stauts => Status::Pending) }
  scope :won,     lambda { where(:status => Status::Won) }
  scope :lost,    lambda { where(:status => Status::Lost) }

  protected

    def _assign_initialization_defaults
      self.status = Status::Pending
    end

  module Status
    Pending = 'pending'
    Won     = 'won'
    Lost    = 'lost'
  end
end
