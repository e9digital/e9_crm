# An email campaign.
#
class EmailCampaign < Campaign

  ##
  # The sum cost of this campaign
  #
  # NOTE How much does an email campaign 'cost'?
  #
  def cost
    Money.new(1)
  end
end
