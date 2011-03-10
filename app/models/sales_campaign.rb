class SalesCampaign < Campaign
  money_columns :sales_fee
  belongs_to :sales_person

  def cost
    sales_fee
  end
end
