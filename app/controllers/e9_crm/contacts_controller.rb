class E9Crm::ContactsController < E9Crm::ResourcesController
  defaults :resource_class => Contact

  include E9Rails::Controllers::Orderable
  include E9Tags::Controller

  respond_to :js, :html

  carrierwave_column_methods :avatar, :context => :admin

  before_filter :determine_title, :only => :index
  before_filter :load_contact_ids, :only => :index
  before_filter :build_nested_associations, :only => [:new, :edit]
  before_filter :set_tag_instructions_scope

  has_scope :search, :by_title, :by_company, :only => :index
  has_scope :tagged, :only => :index, :type => :array
  has_scope :by_company, :as => :company, :only => :index
  has_scope :bounced_primary_emails, :as => :bounced, :type => :boolean

  # record attributes templates js
  #caches_action :templates
  
  skip_before_filter :authenticate_user!, :filter_access_filter, :only => :templates
  before_filter :build_resource, :only => :templates
  before_filter :set_edit_title, :only => :edit

  def templates
    render RecordAttribute::TEMPLATES
  end

  # NOTE for some reason create! { redirect } is trying to redirect on failure
  def create
    create! do |success, failure|
      success.html { redirect_to resource_path }
      failure.html { render :new }
    end
  end

  def update
    update! { resource_path }
  end

  protected

  #
  # Load all contact ids for the request (no pagination) using a direct sql query
  # for the contact_id rather than loading all contacts.
  #
  def load_contact_ids
    @contact_ids ||= begin
      contact_id_sql = end_of_association_chain.scoped.ok_to_email.select('contacts.id').to_sql
      Contact.connection.send(:select_values, contact_id_sql, 'Contact ID Load')
    end
  end

  #
  # Change title depending on search params (tags & search)
  #
  def determine_title
    params.delete(:search) if params[:search].blank?
    
    @index_title = 'Contacts'.tap do |t|
      if params[:search]
        t << " matching \"#{params[:search]}\""
      end
      if params[:tagged]
        t << " tagged #{params[:tagged].map {|t| "\"#{t}\"" }.join(' or ')}"
      end
      if params[:company] =~ /\d+/ && company = Company.find_by_id(params[:company])
        t << " in company \"#{company.name}\""
      end
    end
  end

  def set_edit_title
    @edit_title ||= e9_t(:edit_title_with_name, :contact => resource.name)
  end

  # we don't need @index_title in the breadcrumb here (too long)
  def add_index_breadcrumb
    add_breadcrumb! e9_t(:index_title), collection_path
  end

  def collection_scope
    #TODO fix eager loading, which totally breaks because of the left outer joins in search
    #super.includes(:users => :subscriptions)
    scope = super
  end

  def set_tag_instructions_scope
    @tag_instructions_scope = 'activerecord.attributes.contact'
  end

  def build_nested_associations
    object = params[:id] ? resource : build_resource
    object.build_all_record_attributes
  end

  def default_ordered_on
    'first_name'
  end

  def default_ordered_dir
    'ASC'
  end
end
