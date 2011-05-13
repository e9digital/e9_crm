class E9Crm::AdvertisingCampaignsController < E9Crm::ResourcesController
  defaults :resource_class => AdvertisingCampaign
  include E9Rails::Controllers::Orderable
end
