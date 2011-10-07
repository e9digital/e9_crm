class E9Crm::LeadsController < ApplicationController
  # NOTE this controller, contrary to sanity, doesn't handle admin/crm/leads,
  #      rather it handles only public side lead creation

  # TODO these should all be included in e9_base
  include E9Rails::Helpers::Title
  include E9Rails::Helpers::Translation
  include E9Rails::Helpers::ResourceErrorMessages

  include E9::Controllers::CheckboxCaptcha

  inherit_resources
  belongs_to :offer, :param => :public_offer_id
  defaults :resource_class => Deal, :instance_name => 'deal'

  respond_to :js
  respond_to :html, :only => []

  has_scope :leads, :type => :boolean, :default => true

  # we want to control (or not use) our own flash messages
  skip_after_filter :flash_to_headers

  before_filter :association_chain
  after_filter :install_offers_cookie, :only => :create

  #
  # In the case that this is actually an HTML request, redirect to
  # the offer on success (regardless of what type of offer?)
  #
  def create
    create!(:flash => false) do |success, failure|
      success.html { redirect_to public_offer_path(@offer) }
      success.js
    end
  end

  protected

  def create_resource(object)
    @lead_was_created = object.save
  end

  def build_resource
    get_resource_ivar || set_resource_ivar(
      # NOTE mailing list ids come from the form (to allow opt-outs)
      Deal.leads.new((params[resource_instance_name] || {}).reverse_merge(
        :user             => current_user,
        :offer            => @offer,
        :campaign         => tracking_campaign
      ))
    )
  end

  #
  # this cookie is installed after successfully creating a lead and once installed,
  # allows the cookied user to view the public offer page for the parent @offer
  #
  def install_offers_cookie 
    if @lead_was_created
      cookied_offer_array = Marshal.load(cookies['_e9_offers']) rescue []

      cookied_offer_array |= [@offer.id]

      cookies['_e9_offers'] = {
        :value   => Marshal.dump(cookied_offer_array),
        :expires => 1.year.from_now
      }
    end
  end

  def determine_layout
    request.xhr? ? false : super
  end

  def find_current_page
    @current_page ||= Offer.page || super
  end
end
