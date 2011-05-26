class E9Crm::CompaniesController < E9Crm::ResourcesController
  defaults :resource_class => Company
  include E9Rails::Controllers::Orderable
  include E9::DestroyRestricted::Controller

  protected

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end
end
