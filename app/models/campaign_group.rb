# An arbitrary grouping of campaigns for organizational use
#
class CampaignGroup < ActiveRecord::Base
  has_many :campaigns

  def to_s
    name
  end
end
