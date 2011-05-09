# Generated from an offer
#
class Lead < ActiveRecord::Base
  belongs_to :offer, :inverse_of => :lead
  has_many :deals, :inverse_of => :lead
end
