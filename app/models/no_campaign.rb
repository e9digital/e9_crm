class NoCampaign < Campaign
  def name
    self.class.human_attribute_name(:name)
  end
end
