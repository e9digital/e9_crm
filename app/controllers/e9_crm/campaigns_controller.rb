class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign

  has_scope :of_type, :as => :t, :only => :index

  def update
    update! { collection_url }
  end

  protected

  def resource_class
    @_campaign_class ||= case request.path
    when /campaigns\/sales/       then SalesCampaign
    when /campaigns\/affiliate/   then AffiliateCampaign
    when /campaigns\/email/       then EmailCampaign
    when /campaigns\/advertising/ then AdvertisingCampaign
    else super
    end
  end
end
