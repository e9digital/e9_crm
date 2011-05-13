class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign
  include E9Rails::Controllers::Orderable

  filter_access_to :reports, :require => :read, :context => :admin

  has_scope :of_group, :as => :group, :only => :index

  has_scope :active, :only => :index do |_, scope, value|
    scope.active(E9.true_value?(value))
  end

  has_scope :of_type, :as => :type, :only => :index do |_, scope, value|
    scope.of_type("#{value}_campaign".classify)
  end

  def reports
    index!
  end

  protected

  def set_reports_index_title
    @index_title = I18n.t(:reports_title, :scope => 'e9.e9_crm.campaigns')
  end
  
  # no pagination
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
  end
end
