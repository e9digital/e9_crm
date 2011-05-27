class E9Crm::EmailTemplatesController < E9Crm::ResourcesController
  defaults
  include E9Rails::Controllers::Orderable
  self.should_paginate_index = false

  before_filter :handle_unacceptable_mimetype, :only => :show

  respond_to :json, :only => :show
  respond_to :html, :except => :show

  def show
    unless params[:contact_id] =~ /\d+/ && @contact = Contact.find_by_id(params[:contact_id])
      head :status => 404
    else
      object           = resource
      object.contact   = @contact
      object.recipient = @contact.primary_user

      render :json => object
    end
  end

  protected

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end
end
