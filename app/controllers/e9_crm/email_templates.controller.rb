class E9Crm::EmailTemplatesController < E9Crm::ResourcesController
  defaults
  include E9Rails::Controllers::Orderable
  self.should_paginate_index = false
end
