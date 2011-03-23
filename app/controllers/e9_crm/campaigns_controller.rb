class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign

  def update
    update! { collection_url }
  end

  protected

  def resource_class
    @_campaign_class ||= case params[:campaign_type]
    when 'sales'       then SalesCampaign
    when 'affiliate'   then AffiliateCampaign
    when 'email'       then EmailCampaign
    when 'advertising' then AdvertisingCampaign
    else super
    end
  end
end
