class E9Crm::ResourcesController < E9Crm::BaseController
  include E9Rails::Helpers::ResourceErrorMessages
  include E9Rails::Helpers::Pagination

  inherit_resources

  class << self
    #
    # InheritedResources wants to namespace its helper routes based on the controller, 
    # and would prefix all routes by default.  But our routes are not namepaced, so we
    # override the route_prefix back to null.
    #
    #def defaults(hash = {})
      #super hash.reverse_merge(:route_prefix => nil)
    #end
  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(pagination_parameters))
  end
end
