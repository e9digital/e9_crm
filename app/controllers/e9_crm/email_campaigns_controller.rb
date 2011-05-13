class E9Crm::EmailCampaignsController < E9Crm::ResourcesController
  defaults :resource_class => EmailCampaign
  include E9Rails::Controllers::Orderable
end
