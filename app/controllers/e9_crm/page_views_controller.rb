class E9Crm::PageViewsController < E9Crm::ResourcesController
  defaults :resource_class => PageView
  belongs_to :campaign, :contact, :polymorphic => true

  # NOTE association chain is prepended to ensure parent is loaded so other
  #      before filters can use collection_path, etc.  Is there a better solution
  #      for this?
  #
  prepend_before_filter :association_chain
end
