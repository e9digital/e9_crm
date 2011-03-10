class E9Crm::ResourceController < InheritedResources::Base
  include E9Rails::Helpers::ResourceErrorMessages
  include E9Rails::Helpers::Translation
  include E9Rails::Helpers::Title

  class << self
    def defaults(hash = {})
      super hash.reverse_merge(
        :route_prefix => nil
      )
    end
  end

  protected

  def page
    params[:page] || 1
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(:page => page, :per_page => 10))
  end
end
