class NoCampaign < Campaign
  def name
    self.class.model_name.human
  end

  def cost
    0
  end

  def code
    'NoCode'
  end
end
