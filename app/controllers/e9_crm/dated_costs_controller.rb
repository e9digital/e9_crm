class E9Crm::DatedCostsController < E9Crm::ResourcesController
  belongs_to :advertising_campaign, :optional => true
  defaults :resource_class => DatedCost
  include E9Rails::Controllers::Orderable

  self.should_paginate_index = true

  filter_access_to :bulk_create, :require => :create, :context => :admin

  prepend_before_filter :association_chain
  before_filter :add_breadcrumbs
  before_filter :generate_temp_id, :only => :new

  respond_to :json, :only => :new

  def index
    if params[:advertising_campaign_id]
      @index_title = "Advertising Costs for #{parent.name}" if parent
      index!
    else
      @advertising_campaigns = AdvertisingCampaign.all
      render 'bulk_form'
    end
  end

  def new
    new! do |format|
      format.html
      format.json { render :json => { :html => render_html_for_action } }
    end
  end

  def bulk_create
    params[:id].zip(params[:cost]) do |id, cost|
      DatedCost.create(
        :costable_id   => id,
        :costable_type => AdvertisingCampaign.base_class.name,
        :date          => params[:date],
        :cost          => cost
      )
    end

    flash[:notice] = "Advertising Costs Added"
    redirect_to :marketing_report
  end

  protected

    def render_html_for_action(action = nil)
      action ||= params[:action]

      html = nil

      lookup_context.update_details(:formats => [Mime::HTML.to_sym]) do
        html = render_to_string(action, :layout => false)
      end

      html
    end

    def default_ordered_on
      'date'
    end

    def default_ordered_dir
      'ASC'
    end

    def add_index_breadcrumb
      add_breadcrumb! Campaign.model_name.collection.titleize, campaigns_path

      if parent
        add_breadcrumb! parent.name, edit_advertising_campaign_path(parent)
      end
    end

    def add_breadcrumbs
      add_breadcrumb! e9_t(:index_title)
    end

    def determine_layout
      request.xhr? ? false : super
    end

    def generate_temp_id
      @temp_id ||= DateTime.now.to_i
    end
end
