#
# Encapulates a Cost and a Date, used to track costs by
# date so sums for date ranges can be generated.
#
class DatedCost < ActiveRecord::Base
  money_columns :cost
  belongs_to :costable, :polymorphic => true
  validates :date, :date => true
end
