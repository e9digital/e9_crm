class E9Crm::DatedCostsController < E9Crm::CampaignSubclassController
  belongs_to :advertising_campaign, :optional => true
  defaults :resource_class => DatedCost
  include E9Rails::Controllers::Orderable

  filter_access_to :bulk_create, :require => :create, :context => :admin

  before_filter :add_breadcrumbs
  before_filter :generate_temp_id, :only => :new

  def index
    if params[:advertising_campaign_id]
      index!
    else
      @advertising_campaigns = AdvertisingCampaign.all
      render 'bulk_form'
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

    def collection
      get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
    end

    def default_ordered_on
      'date'
    end

    def default_ordered_dir
      'ASC'
    end

    def add_breadcrumbs
      if parent?
        add_breadcrumb! parent.name, edit_advertising_campaign_path(parent)
      end

      add_breadcrumb! e9_t(:index_title)
    end

    def determine_layout
      request.xhr? ? false : super
    end

    def generate_temp_id
      @temp_id ||= DateTime.now.to_i
    end
end
