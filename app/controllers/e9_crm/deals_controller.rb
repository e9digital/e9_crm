class E9Crm::DealsController < E9Crm::ResourcesController
  defaults :resource_class => Deal
  include E9Rails::Controllers::Orderable

  # for campaign select options
  helper :"e9_crm/campaigns"

  filter_access_to :leads, :reports, :require => :read, :context => :admin

  prepend_before_filter :set_leads_index_title, :only => :leads
  prepend_before_filter :set_reports_index_title, :only => :reports

  ##
  # Index/Reports Scopes
  #

  # NOTE default => 'true' only exists to ensure this scope is called
  has_scope :only_leads, :only => :leads, :default => 'true' do |controller, scope|
    scope.leads(true)
  end

  # NOTE default => 'false' only exists to ensure this scope is called
  has_scope :no_leads, :only => :index, :default => 'false' do |controller, scope|
    scope.leads(false)
  end

  ##
  # Index Scopes
  #

  has_scope :category, :only => :index
  has_scope :status, :only => :index
  has_scope :owner, :only => :index

  ##
  # Reports scopes
  #

  has_scope :reports, :only => :reports, :type => :boolean, :default => true

  has_scope :group, :only => :reports do |c, scope, value|
    scope & Campaign.of_group(value)
  end

  has_scope :type, :only => :reports do |_, scope, value|
    scope & Campaign.of_type("#{value}_campaign".classify)
  end

  has_scope :until_time, :as => :until, :unless => 'params[:from].present?'

  has_scope :from_time, :as => :from do |controller, scope, value|
    if controller.params[:until]
      scope.for_time_range(value, controller.params[:until])
    else
      scope.from_time(value)
    end
  end

  ##
  # Actions
  #

  def leads
    index!
  end

  def reports
    index!
  end

  protected

  def collection
    get_collection_ivar || begin
      set_collection_ivar(
        if params[:action] == 'reports'
          end_of_association_chain.all
        else
          end_of_association_chain
            .joins("left outer join contacts on contacts.id = deals.contact_id")
            .select("deals.*, contacts.first_name owner_name")
        end
      )
    end
  end

  def set_leads_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.leads')
  end

  def set_reports_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.reports')
  end

  def ordered_if 
    %w(index reports).member? params[:action]
  end
end
