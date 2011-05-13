class E9Crm::SalesCampaignsController < E9Crm::ResourcesController
  defaults :resource_class => SalesCampaign
  include E9Rails::Controllers::Orderable
end
