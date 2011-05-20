class E9Crm::LeadsController < ApplicationController
  # TODO these should all be included in e9_base
  include E9Rails::Helpers::ResourceLinks
  include E9Rails::Helpers::Title
  include E9Rails::Helpers::Translation
  include E9Rails::Helpers::ResourceErrorMessages

  inherit_resources
  belongs_to :offer
  defaults :resource_class => Deal, :instance_name => 'deal'

  has_scope :leads

  before_filter :params_for_build, :only => :new

  respond_to :js

  def create
    object = build_resource

    if object.user.blank?

    end

    create!
  end

  protected

  def params_for_build 
    params[resource_instance_name]           ||= {}
    params[resource_instance_name][:user_id] ||= current_user.id if current_user
    params[resource_instance_name]
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
