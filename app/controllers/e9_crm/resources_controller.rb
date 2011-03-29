class E9Crm::ResourcesController < E9Crm::BaseController
  include E9Rails::Helpers::ResourceErrorMessages
  include E9Rails::Helpers::Pagination

  inherit_resources

  add_resource_breadcrumbs

  class << self
    #
    # InheritedResources wants to namespace its helper routes based on the controller, 
    # and would prefix all routes by default.  But our routes are not namepaced, so we
    # override the route_prefix back to null.  (Otherwise IR will attempt to resolve
    # paths like e9_crm_contacts_path, etc, whereas the path is simply contacts_path)
    #
    def defaults(hash = {})
      super hash.reverse_merge(:route_prefix => nil)
    end
  end

  protected

  def add_index_breadcrumb
    # NOTE need to override this because AdminController paths admin_ prefix
    add_breadcrumb! e9_t(:index_title), polymorphic_path(resource_class)
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(pagination_parameters))
  end
end
