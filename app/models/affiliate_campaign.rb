# An affiliate campaign
#
# Carries an affiliate fee (and sales fee)
#
class AffiliateCampaign < SalesCampaign
  money_columns :affiliate_fee
  belongs_to :affiliate 

  ##
  # The sum cost of this campaign
  #
  def cost
    super + affiliate_fee
  end
end
