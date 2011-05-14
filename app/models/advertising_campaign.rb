# An ad driven campaign.
#
# Unique from other campaigns in that their cost is derived from associated
# DatedCost records.
#
class AdvertisingCampaign < Campaign

  ##
  # The sum cost of this campaign
  #
  def cost
    Money.new(dated_costs.sum(:cost))
  end
end
