class E9Crm::OffersController < E9Crm::ResourcesController
  defaults :resource_class => Offer
  include E9Rails::Controllers::Orderable
  self.should_paginate_index = false

  # record attributes templates js
  skip_before_filter :authenticate_user!, :filter_access_filter, :only => :show

  before_filter :throw_forbidden_unless_offer_cookied, :only => :show

  has_scope :of_type, :as => :type, :only => :index do |_, scope, value|
    scope.of_type("#{value}_offer".classify)
  end

  def show
    clear_breadcrumbs
    add_home_crumb
    add_breadcrumb! @show_title = resource.name
  end

  protected

  def throw_forbidden_unless_offer_cookied
    cookied_offer_array = Marshal.load(cookies['_e9_offers']) rescue []

    unless cookied_offer_array.member?(params[:id].to_i)
      permission_denied and return false
    end
  end

  def find_current_page
    if params[:action] != 'show'
      super
    else
      @current_page ||= Offer.page || super
    end
  end

  def determine_layout
    request.xhr? ? false : super
  end

  def default_ordered_on
    :name
  end

  def default_ordered_dir
    :ASC
  end
end
