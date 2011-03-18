class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  has_scope :tagged

  include E9Tags::Controller

  before_filter :determine_title, :only => :index

  protected

  def determine_title
    if params[:tagged]
      @index_title = e9_t(:index_title_with_search, :tags => params[:tagged])
    end
  end
end
