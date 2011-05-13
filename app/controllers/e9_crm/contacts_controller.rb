class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  include E9Rails::Controllers::Orderable
  include E9Tags::Controller

  respond_to :js, :html

  before_filter :determine_title, :only => :index
  before_filter :load_contact_ids, :only => :index

  has_scope :search, :by_title, :by_company, :only => :index
  has_scope :tagged, :only => :index, :type => :array

  # record attributes templates js
  skip_before_filter :authenticate_user!, :filter_access_filter, :only => :templates
  before_filter :build_resource, :only => :templates
  caches_action :templates

  protected

  def load_contact_ids
    @contact_ids ||= begin
      contact_id_sql = end_of_association_chain.scoped.select('contacts.id').to_sql
      Contact.connection.send(:select_values, contact_id_sql, 'Contact ID Load')
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

  def default_ordered_on
    'first_name'
  end

  def default_ordered_at
    'ASC'
  end
end
