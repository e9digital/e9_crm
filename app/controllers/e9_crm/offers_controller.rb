class E9Crm::OffersController < E9Crm::ResourcesController
  defaults :resource_class => Offer
  include E9Rails::Controllers::Orderable
  self.should_paginate_index = false

  has_scope :of_type, :as => :type, :only => :index do |_, scope, value|
    scope.of_type("#{value}_offer".classify)
  end
end
