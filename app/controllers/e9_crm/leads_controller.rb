class E9Crm::LeadsController < ApplicationController
  # TODO these should all be included in e9_base
  include E9Rails::Helpers::ResourceLinks
  include E9Rails::Helpers::Title
  include E9Rails::Helpers::Translation
  include E9Rails::Helpers::ResourceErrorMessages

  inherit_resources
  belongs_to :offer, :param => :public_offer_id
  defaults :resource_class => Deal, :instance_name => 'deal'

  # we want to control (or not use) our own flash messages
  skip_after_filter :flash_to_headers

  respond_to :js
  respond_to :html, :only => []

  has_scope :leads, :type => :boolean, :default => true

  after_filter :install_offers_cookie, :only => :create

  protected

  def build_resource
    get_resource_ivar || set_resource_ivar(Deal.leads.new(build_params))
  end

  def create_resource(object)
    @lead_was_created = object.save
  end

  def build_params
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:user_id] = current_user.id if current_user
    params[resource_instance_name]
  end

  def install_offers_cookie 
    cookied_offer_array = Marshal.load(cookies['_e9_offers']) rescue []

    cookied_offer_array |= [@offer.id]

    cookies['_e9_offers'] = {
      :value   => Marshal.dump(cookied_offer_array),
      :expires => 1.year.from_now
    }
  end

  def determine_layout
    request.xhr? ? false : super
  end

  def find_current_page
    @current_page ||= Offer.page || super
  end
end
