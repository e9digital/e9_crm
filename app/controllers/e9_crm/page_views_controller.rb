class E9Crm::PageViewsController < E9Crm::ResourcesController
  defaults :resource_class => PageView
  include E9::Controllers::Orderable

  actions :index

  # NOTE association chain is prepended to ensure parent is loaded so other
  #      before filters can use collection_path, etc.  Is there a better solution
  #      for this?
  #
  prepend_before_filter :association_chain

  before_filter :find_contact

  has_scope :campaign, :only => :index do |_, scope, value|
    scope.where(:campaign_id => value)
  end

  has_scope :contact, :only => :index do |_, scope, value|
    scope.joins(:user => :contact).merge(Contact.where(:id => value))
  end

  has_scope :new_visits, :only => :index, do |_, scope, value|
    scope.new_visits(E9.true_value?(value))
  end

  has_scope :month, :only => :index do |controller, scope, value|
    scope.for_time_range(value, :in => :month)
  end

  protected

  def collection_scope
    scope = end_of_association_chain

    unless params[:contact]
      join_sql = <<-SQL
        LEFT OUTER JOIN tracking_cookies
          ON tracking_cookies.id = page_views.tracking_cookie_id
        LEFT OUTER JOIN users
          ON users.id = tracking_cookies.user_id
        LEFT OUTER JOIN contacts
          ON contacts.id = users.contact_id
      SQL

      scope = scope.joins(join_sql)
    end

    sel_sql = <<-SQL
      page_views.*,
      IF(contacts.id,CONCAT_WS(' ', contacts.first_name, contacts.last_name),'(Unknown)') contact_name,
      contacts.id as contact_id
    SQL

    scope.select(sel_sql)
  end

  def collection
    get_collection_ivar || begin
      total_entries = collection_scope.except(:order).count
      objects       = collection_scope.includes(:campaign).paginate(pagination_parameters.merge(:total_entries => total_entries))

      set_collection_ivar objects
    end
  end

  def find_contact
    @contact ||= params[:contact] && Contact.find_by_id(params[:contact])
  end
end
