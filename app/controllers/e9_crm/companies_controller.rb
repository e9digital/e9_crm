class E9Crm::CompaniesController < E9Crm::ResourcesController
  defaults :resource_class => Company
  include E9Rails::Controllers::Orderable
end
