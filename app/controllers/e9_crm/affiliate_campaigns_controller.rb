class E9Crm::AffiliateCampaignsController < E9Crm::ResourcesController
  defaults :resource_class => AffiliateCampaign
  include E9Rails::Controllers::Orderable
end
