class E9Crm::EmailCampaignsController < E9Crm::CampaignSubclassController
  defaults :resource_class => EmailCampaign
  include E9Rails::Controllers::Orderable

  helper 'e9_crm/campaigns'
end
