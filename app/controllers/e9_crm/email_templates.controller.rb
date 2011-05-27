class E9Crm::EmailTemplatesController < E9Crm::ResourcesController
  defaults
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
