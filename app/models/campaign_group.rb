# An arbitrary grouping of campaigns for organizational use
#
class CampaignGroup < ActiveRecord::Base
  has_many :campaigns

  validates :name, :presence => true, :uniqueness => { :allow_nil => true, :case_sensitive => false }

  scope :ordered, lambda { order(arel_table[:name].asc) }

  def to_s
    name
  end
end
