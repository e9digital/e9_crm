class E9Crm::DealsController < E9Crm::ResourcesController
  defaults :resource_class => Deal
  include E9Rails::Controllers::Orderable

  # for campaign select options
  helper :"e9_crm/campaigns"

  filter_access_to :leads, :require => :read, :context => :admin

  skip_after_filter :flash_to_headers, :except => :destroy

  prepend_before_filter :set_leads_index_title, :only => :leads

  before_filter :prepop_deal_owner_contact, :only => [:new, :edit]

  before_filter :redirect_for_default_from_time, :only => :leads

  ##
  # All Scopes
  #

  has_scope :until_time, :as => :until, :unless => 'params[:from].present?'
  has_scope :from_time, :as => :from do |controller, scope, value|
    if controller.params[:until]
      scope.for_time_range(value, controller.params[:until])
    else
      scope.from_time(value)
    end
  end

  has_scope :closed_in_month, :as => :closed, :only => :index do |controller, scope, value|
    scope.for_time_range(value, :column => :closed_at, :in => :month)
  end

  ##
  # Leads Scopes
  #
  
  # NOTE default => 'true' only exists to ensure this scope is called
  has_scope :only_leads, :only => :leads, :default => 'true' do |controller, scope|
    scope.leads(true)
  end

  has_scope :offer, :only => :leads

  ##
  # Index Scopes
  #
  
  # NOTE default => 'false' only exists to ensure this scope is called
  has_scope :no_leads, :only => :index, :default => 'false' do |controller, scope|
    scope.leads(false)
  end

  has_scope :category, :only => :index
  has_scope :status, :only => :index
  has_scope :owner, :only => :index

  ##
  # Actions
  #

  def leads
    index!
  end

  protected

  def add_edit_breadcrumb(opts = {})
    @edit_title = e9_t(resource.lead? ? :new_title : :edit_title)
    add_breadcrumb!(@edit_title)
  end

  # TODO the leads table references offer each row, and it is not joined here
  def collection
    get_collection_ivar || begin
      set_collection_ivar(
        if params[:action] == 'leads'
          end_of_association_chain.includes(:contacts).paginate(pagination_parameters)

        else
          # NOTE this is a pretty ugly join just to be able to sort on owner
          end_of_association_chain
            .joins("left outer join contacts on contacts.id = deals.contact_id")
            .select("deals.*, contacts.first_name owner_name")
            .all
        end
      )
    end
  end

  def prepop_deal_owner_contact
    object = params[:id] ? resource : build_resource

    if !object.owner && contact = current_user.contact
      object.owner = contact
    end
  end

  def set_leads_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.leads')
  end

  def should_paginate_index
    params[:action] == 'leads'
  end

  def ordered_if 
    %w(index leads).member? params[:action]
  end

  def default_ordered_on 
    'name' 
  end

  def default_ordered_dir 
    'ASC' 
  end

  def redirect_for_default_from_time
    format = request.format.blank? || request.format == Mime::ALL ? Mime::HTML : request.format

    if format.html? && params[:from].blank?
      url = params.slice(:controller, :action)
      url.merge!(:from => Date.today.strftime('%Y/%m'))
      redirect_to url and return false
    end
  end
end
