class E9Crm::OfferSubclassController < E9Crm::ResourcesController
  protected

    def add_index_breadcrumb
      add_breadcrumb! Offer.model_name.collection.titleize, offers_path 
    end

    def determine_layout
      request.xhr? ? false : super
    end
end
