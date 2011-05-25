class NoCampaign < Campaign
  #before_create do |record|
    #record.code ||= 'nocode'
  #end

  def name
    self.class.model_name.human
  end
end
