# An arbitrary grouping of campaigns for organizational use
#
class CampaignGroup < ActiveRecord::Base
  has_many :campaigns

  validates :name, :uniqueness => { :ignore_case => true }

  def to_s
    name
  end
end
