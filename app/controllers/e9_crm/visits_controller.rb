class E9Crm::VisitsController < E9Crm::ResourcesController
  defaults :resource_class => PageView, :collection_name => :page_views
  belongs_to :campaign
  include E9::Controllers::Orderable

  actions :index

  # NOTE association chain is prepended to ensure parent is loaded so other
  #      before filters can use collection_path, etc.  Is there a better solution
  #      for this?
  #
  prepend_before_filter :association_chain

  before_filter :determine_title, :only => :index

  has_scope :visits, :default => 'true' do |_, scope, _|
    sel_sql  = <<-SQL
      page_views.*,
      IF(contacts.id,CONCAT_WS(' ', contacts.first_name, contacts.last_name),'(Unknown)') contact_name,
      contacts.id as contact_id,
      count(distinct(if(page_views.new_visit=1,IFNULL(page_views.session,1),null))) as new_visits,
      count(distinct(if(page_views.new_visit=1,null,IFNULL(page_views.session,1)))) as repeat_visits
    SQL

    join_sql = <<-SQL
      LEFT OUTER JOIN tracking_cookies
        ON tracking_cookies.id = page_views.tracking_cookie_id
      LEFT OUTER JOIN users
        ON users.id = tracking_cookies.user_id
      LEFT OUTER JOIN contacts
        ON contacts.id = users.contact_id
    SQL
      
    scope.select(sel_sql).joins(join_sql).group('contact_id')
  end

  protected

  def collection
    get_collection_ivar || begin
      set_collection_ivar end_of_association_chain.paginate(pagination_parameters)
    end
  end

  def default_ordered_dir
    'ASC'
  end

  def default_ordered_on
    'contact_name'
  end

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:breadcrumb_title)
  end

  def determine_title
    @index_title = e9_t(:index_title, :parent => parent.name)
  end
end
