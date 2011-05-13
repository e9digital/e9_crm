class E9Crm::CampaignGroupsController < E9Crm::ResourcesController
  defaults :resource_class => CampaignGroup
  include E9Rails::Controllers::Orderable

  protected
  
  # no pagination
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
  end
end
