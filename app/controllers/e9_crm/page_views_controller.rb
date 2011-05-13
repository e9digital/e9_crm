class E9Crm::PageViewsController < E9Crm::ResourcesController
  defaults :resource_class => PageView
  belongs_to :campaign, :contact, :polymorphic => true
  include E9Rails::Controllers::Orderable

  # NOTE association chain is prepended to ensure parent is loaded so other
  #      before filters can use collection_path, etc.  Is there a better solution
  #      for this?
  #
  prepend_before_filter :association_chain

  has_scope :until_time, :as => :until, :unless => 'params[:from].present?'

  has_scope :from_time, :as => :from do |controller, scope, value|
    if controller.params[:until]
      scope.for_time_range(value, controller.params[:until])
    else
      scope.from_time(value)
    end
  end
end
