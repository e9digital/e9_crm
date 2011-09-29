class E9Crm::ResourcesController < E9Crm::BaseController
  inherit_resources

  include E9Rails::Helpers::ResourceErrorMessages
  include E9::Controllers::InheritableViews

  # NOTE depending on e9_base pagination (which should eventually use this module)
  #include E9Rails::Helpers::Pagination
  include E9::DestroyRestricted::Controller

  # TODO implement role on e9_crm models?
  #include E9::Roles::Controller
  #filter_access_to :update, :edit, :attribute_check => true, :load_method => :filter_target, :context => :admin

  class_inheritable_accessor :should_paginate_index
  self.should_paginate_index = true

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

  def should_paginate_index
    self.class.should_paginate_index
  end

  def filter_target
    resource
  end

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

  def build_params
    params[resource_instance_name] || {}
  end

  def build_resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.send(method_for_build, build_params))
  end

  def default_ordered_on
    'created_at'
  end

  def default_ordered_dir
    'DESC'
  end
end
