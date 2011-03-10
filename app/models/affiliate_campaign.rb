class AffiliateCampaign < SalesCampaign
  money_columns :affiliate_fee
  belongs_to :affiliate 

  def cost
    super + affiliate_fee
  end
end
