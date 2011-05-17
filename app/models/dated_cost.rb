#
# Encapulates a Cost and a Date, used to track costs by
# date so sums for date ranges can be generated.
#
class DatedCost < ActiveRecord::Base
  include E9Rails::ActiveRecord::Initialization

  money_columns :cost
  belongs_to :costable, :polymorphic => true
  validates :date, :date => true
  validates :cost, :numericality => { :greater_than => 0 }

  attr_accessor :temp_id

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]            = self.id
      hash[:cost]          = self.cost
      hash[:date]          = self.date
      hash[:costable_type] = self.costable_type.try(:underscore)
      hash[:costable_id]   = self.costable_id
      hash[:errors]        = self.errors

      hash.merge!(options)
    end
  end

  protected

    def _assign_initialization_defaults
      self.date ||= Date.today
    end
end
