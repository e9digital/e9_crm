class E9Crm::DealsController < E9Crm::ResourcesController
  defaults :resource_class => Deal
  include E9Rails::Controllers::Orderable

  filter_access_to :leads, :require => :read, :context => :admin
  prepend_before_filter :set_leads_index_title, :only => :leads

  has_scope :leads, :only => :leads, :default => true
  has_scope :leads, :except => :leads, :default => false

  def leads
    index!
  end

  protected

  def collection_scope
  end

  def set_leads_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.leads')
  end
end
