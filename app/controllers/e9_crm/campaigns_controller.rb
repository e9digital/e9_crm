class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign
  has_scope :of_type, :as => :t, :only => :index
end
