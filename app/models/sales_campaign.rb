# An sales campaign
#
# Carries an affiliate fee
#
class SalesCampaign < Campaign
  money_columns :sales_fee

  belongs_to :sales_person, :class_name => 'Contact'
  validates :sales_person, :presence => { :if => lambda {|x| x.type == 'SalesCampaign' } }

  ##
  # The sum cost of this campaign
  #
  def cost
    sales_fee
  end
end
