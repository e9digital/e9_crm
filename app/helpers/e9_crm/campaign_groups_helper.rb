module E9Crm::CampaignGroupsHelper
  def records_table_field_map_for_campaign_group
    {
      :fields => { 'name' => nil },
      :links => proc {|r| [link_to_edit_resource(r), link_to_destroy_resource(r)] }
    }
  end
end
