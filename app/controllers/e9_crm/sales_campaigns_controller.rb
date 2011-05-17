class E9Crm::SalesCampaignsController < E9Crm::CampaignSubclassController
  defaults :resource_class => SalesCampaign
  include E9Rails::Controllers::Orderable
end
