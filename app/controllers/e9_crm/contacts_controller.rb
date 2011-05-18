class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  include E9Rails::Controllers::Orderable
  include E9Tags::Controller

  respond_to :js, :html

  carrierwave_column_methods :avatar, :context => :admin

  before_filter :determine_title, :only => :index
  before_filter :load_contact_ids, :only => :index
  before_filter :build_nested_associations, :only => [:new, :edit]

  has_scope :search, :by_title, :by_company, :only => :index
  has_scope :tagged, :only => :index, :type => :array

  # record attributes templates js
  skip_before_filter :authenticate_user!, :filter_access_filter, :only => :templates
  before_filter :build_resource, :only => :templates
  caches_action :templates

  protected

  #
  # Load all contact ids for the request (no pagination) using a direct sql query
  # for the contact_id rather than loading all contacts.
  #
  def load_contact_ids
    @contact_ids ||= begin
      contact_id_sql = end_of_association_chain.scoped.select('contacts.id').to_sql
      Contact.connection.send(:select_values, contact_id_sql, 'Contact ID Load')
    end
  end

  #
  # Change title depending on search params (tags & search)
  #
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

  def build_nested_associations
    object = params[:id] ? resource : build_resource
    object.build_all_record_attributes
  end

  def default_ordered_on
    'first_name'
  end

  def default_ordered_at
    'ASC'
  end
end
