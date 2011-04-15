class E9Crm::ResourcesController < E9Crm::BaseController
  include E9Rails::Controllers::Orderable
  include E9Rails::Helpers::ResourceErrorMessages
  include E9Rails::Helpers::Pagination

  inherit_resources

  add_resource_breadcrumbs

  def self.defaults(hash = {})
    super(hash.reverse_merge(:route_prefix => nil))
  end

  def create
    create! { collection_path }
  end

  def update
    update! { collection_path }
  end

  protected

  def add_index_breadcrumb
    # NOTE need to override this because AdminController paths admin_ prefix
    add_breadcrumb! e9_t(:index_title), polymorphic_path(resource_class)
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(pagination_parameters))
  end

  def default_ordered_on
    'created_at'
  end

  def default_ordered_dir
    'DESC'
  end
end
