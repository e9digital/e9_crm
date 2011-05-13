class E9Crm::DatedCostsController < E9Crm::ResourcesController
  belongs_to :advertising_campaign
  defaults :resource_class => DatedCost
  include E9Rails::Controllers::Orderable
end
