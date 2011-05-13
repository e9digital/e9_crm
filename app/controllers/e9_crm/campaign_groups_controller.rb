class E9Crm::CampaignGroupsController < E9Crm::ResourcesController
  defaults :resource_class => CampaignGroup
  include E9Rails::Controllers::Orderable
end
