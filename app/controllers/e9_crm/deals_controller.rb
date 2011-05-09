class E9Crm::DealsController < E9Crm::ResourcesController
  defaults :resource_class => Deal

  filter_access_to :leads, :require => :read, :context => :admin

  has_scope :leads, :only => :leads, :default => true
  has_scope :converted, :except => :leads, :default => true

  def leads
    index!
  end
end
