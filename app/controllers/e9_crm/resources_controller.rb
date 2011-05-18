class E9Crm::ResourcesController < E9Crm::BaseController
  include E9Rails::Helpers::ResourceErrorMessages
  include E9Rails::Helpers::Pagination

  class_inheritable_accessor :should_paginate_index
  self.should_paginate_index = true

  inherit_resources

  respond_to :js

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

  # NOTE parent is defined so it's always available, it will be overridden on controllers which have belongs_to routes
  def parent; end
  helper_method :parent

  def add_index_breadcrumb
    yield if block_given?
    add_breadcrumb! @index_title || e9_t(:index_title), collection_path
  end

  # expose collection scope to be overridden
  def collection_scope
    end_of_association_chain
  end

  def collection
    get_collection_ivar || begin 
      set_collection_ivar(
        collection_scope.send *(should_paginate_index ? [:paginate, pagination_parameters] : [:all])
      )
    end
  end

  def default_ordered_on
    'created_at'
  end

  def default_ordered_dir
    'DESC'
  end
end
