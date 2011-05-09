class E9Crm::MenuOptionsController < E9Crm::ResourcesController
  defaults :resource_class => MenuOption
  include E9Rails::Controllers::Sortable

  has_scope :options_for, :as => :key, :only => :index

  # NOTE The reason this is set in a filter instead of just a default scope value 
  #      is that it is used in the index view to add the key param to the new 
  #      resource link
  #
  before_filter :ensure_default_fetch_key, :only => :index

  def create
    create! { collection_path(:key => resource.key) }
  end

  def update
    update! { collection_path(:key => resource.key) }
  end

  protected

  def ensure_default_fetch_key
    params[:key] ||= MenuOption::KEYS.sort.first
  end
end
