module E9Crm::DealsHelper
  def records_table_field_map_for_deal
    {
      :fields => { 
        :created_at => nil,
        :offer => nil,
        :campaign => nil
      },

      :links => proc {|r|
        []
      }
    }
  end
end
