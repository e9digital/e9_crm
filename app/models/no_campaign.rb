class NoCampaign < Campaign
  def name
    self.class.model_name.human
  end

  def cost
    0
  end
end
