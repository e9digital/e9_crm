class E9Crm::CampaignsController < E9Crm::ResourcesController
  defaults :resource_class => Campaign
  include E9Rails::Controllers::Orderable

  self.should_paginate_index = false

  has_scope :of_group, :as => :group, :only => :index

  has_scope :active, :only => :index, :default => 'true' do |_, scope, value|
    scope.active(E9.true_value?(value))
  end

  has_scope :of_type, :as => :type, :only => :index do |_, scope, value|
    scope.of_type("#{value}_campaign".classify)
  end

  protected

    def collection_scope
      end_of_association_chain.typed.includes(:campaign_group)

      # NOTE this is a pretty ugly join just to be able to sort on campaign group name
      end_of_association_chain.typed
        .joins("left outer join campaign_groups on campaign_groups.id = campaigns.campaign_group_id")
        .select("campaigns.*, campaign_groups.name campaign_group_name")
    end

    def default_ordered_on
      'campaign_group_name,name'
    end

    def default_ordered_dir
      'ASC'
    end

end
