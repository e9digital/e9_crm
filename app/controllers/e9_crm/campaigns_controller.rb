class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign
  include E9Rails::Controllers::Orderable

  helper :"e9_crm/deals"

  before_filter :redirect_new_to_subclass, :only => :new

  before_filter :redirect_for_default_from_time, :only => :reports

  prepend_before_filter :set_reports_index_title, :only => :reports

  filter_access_to :reports, :require => :read, :context => :admin

  self.should_paginate_index = false

  has_scope :active, :only => :index, :default => 'true' do |_, scope, value|
    scope.active(E9.true_value?(value))
  end

  ##
  # Reports
  #

  has_scope :reports, :only => :reports, :default => 'true' do |controller, scope, _|
    if (args = controller.params.values_at(:from, :until)).any?
      scope.reports(*args)
    else
      scope.reports
    end
  end

  has_scope :of_group, :as => :group, :only => :reports

  has_scope :type, :only => [:reports, :index] do |_, scope, value|
    scope.of_type("#{value}_campaign".classify)
  end

  def reports
    index!
  end

  protected

  def redirect_new_to_subclass
    types = %w(advertising affiliate email sales)
    type = types.member?(params[:type]) ? params[:type] : types.first
    redirect_to send("new_#{type}_campaign_path")
  end

  def collection_scope
    if reports?
      end_of_association_chain

    else
      end_of_association_chain.typed
        .joins("left outer join campaign_groups on campaign_groups.id = campaigns.campaign_group_id")
        .select("campaigns.*, campaign_groups.name campaign_group_name")
    end
  end

  def default_ordered_on
    'type,campaign_group_name,name'
  end

  def default_ordered_dir
    'ASC'
  end

  def reports?
    params[:action] == 'reports'
  end

  def set_reports_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.reports')
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
