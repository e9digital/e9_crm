class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  include E9Tags::Controller
end
