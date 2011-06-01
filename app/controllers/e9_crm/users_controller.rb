class E9Crm::UsersController < ApplicationController
  inherit_resources

  respond_to :html, :except => :new
  respond_to :json, :only => :new

  def new
    new! do |format|
      format.json { render :json => resource }
    end
  end

  protected

  def build_resource
    get_resource_ivar || begin
      user = User.new(params[resource_instance_name] || {})
      user.valid?
      set_resource_ivar(user)
    end
  end
end
