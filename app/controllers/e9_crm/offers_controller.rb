class E9Crm::OffersController < E9Crm::ResourcesController
  defaults :resource_class => Offer
  include E9Rails::Controllers::Orderable
end
