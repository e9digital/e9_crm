class E9Crm::CampaignSubclassController < E9Crm::ResourcesController

  def update
    update! { parent_redirect_path }
  end

  def create
    create! { parent_redirect_path }
  end

  protected

    def parent_redirect_path
      campaigns_path(:type => type_param)
    end

    def type_param
      resource_class.name[/(.*)Campaign/, 1].underscore rescue nil
    end

    def add_index_breadcrumb
      add_breadcrumb! Campaign.model_name.collection.titleize, campaigns_path
    end
end
