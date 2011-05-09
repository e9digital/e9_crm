module E9Crm::CampaignsHelper
  def records_table_map_for_campaign
    { 
      :fields => {
        :type => nil, 
        :name => nil, 
        :code => nil, 
        :affiliate_fee => proc {|r| v = r.affiliate_fee; Money === v ? v : 'n/a' },  
        :sales_fee => nil, 
        :status => proc {|r| resource_class.human_attribute_name(Campaign::Status::VALUES[r.status]) } 
      }
    }
  end
end
