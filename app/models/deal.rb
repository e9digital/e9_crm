# Generated from a Lead, owned by a Campaign.  Deals represent potential
# "deals" with contacts and track revenue used for marketing reports.
#
class Deal < ActiveRecord::Base
  belongs_to :campaign

  module Status
    VALUES   = %w(pending won lost)
    PENDING  = 0
    WON      = 1
    LOST     = 2
  end
end
