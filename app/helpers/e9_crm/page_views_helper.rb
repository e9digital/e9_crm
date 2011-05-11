module E9Crm::PageViewsHelper
  def records_table_field_map_for_page_view
    { 
      :fields => {
        :campaign_name => lambda {|record| record.campaign_name || 'n/a' },
        :created_at => nil, 
        :request_path => nil,
        :referer => nil,
        :remote_ip => nil
      },
      
      :links => lambda {|r| [] }
    }
  end
end
