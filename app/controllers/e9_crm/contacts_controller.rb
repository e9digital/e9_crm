class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  respond_to :js, :html

  include E9Tags::Controller

  before_filter :determine_title, :only => :index
  before_filter :load_user_ids, :only => :index

  has_scope :search, :only => :index
  has_scope :tagged, :only => :index, :type => :array
  has_scope :order, :only => :index, :default => 'first_name' do |c,s,v|
    # NOTE first_name ordering is currently forced
    s.order(:first_name)
  end

  # record attributes templates js
  skip_before_filter :authenticate_user!, :filter_access_filter, :only => :templates
  before_filter :build_resource, :only => :templates
  caches_action :templates

  protected

  def load_user_ids
    @user_ids ||= begin
      (User.primary.joins(:contact) & end_of_association_chain.scoped).all.map(&:id)
    end
  end

  def determine_title
    params.delete(:search) if params[:search].blank?

    @index_title ||= if params[:tagged] && params[:search]
      e9_t(:index_title_with_search_and_tags, :tagged => params[:tagged].join(' or '), :search => params[:search])
    elsif params[:tagged]
      e9_t(:index_title_with_tags, :tagged => params[:tagged].join(' or '))
    elsif params[:search]
      e9_t(:index_title_with_search, :search => params[:search])
    end
  end
end
