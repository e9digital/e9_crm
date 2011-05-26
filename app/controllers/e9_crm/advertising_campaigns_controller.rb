class E9Crm::AdvertisingCampaignsController < E9Crm::CampaignSubclassController
  defaults :resource_class => AdvertisingCampaign
  include E9Rails::Controllers::Orderable

  helper 'e9_crm/campaigns'
end
