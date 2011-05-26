class E9Crm::CampaignGroupsController < E9Crm::ResourcesController
  defaults :resource_class => CampaignGroup
  include E9Rails::Controllers::Orderable
  self.should_paginate_index = false

  protected

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end
end
