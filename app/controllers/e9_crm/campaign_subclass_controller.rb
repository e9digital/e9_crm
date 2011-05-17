class E9Crm::CampaignSubclassController < E9Crm::ResourcesController

  protected

    def add_index_breadcrumb
      add_breadcrumb! Campaign.model_name.collection.titleize, campaigns_path
    end
end
