class E9Crm::ContactEmailsController < E9Crm::ResourcesController
  defaults

  respond_to :js, :html

  def create
    create! do |success, failure|
      success.html { redirect_to :admin_sent_email }
      success.js
    end
  end

  protected

  def build_resource
    get_resource_ivar || begin
      object = if params[resource_instance_name]
        ContactEmail.new(params[resource_instance_name] || {})
      else
        ContactEmail.new_from_template(template, :contact_ids => params[:uids])
      end

      object.from_email = object.from_email.presence || current_user.email

      object.valid?

      set_resource_ivar(object)
    end
  end

  # throw record_not_found if there's no template.  #new requires email_template_id
  # be passed in params (and also contact_ids)
  def template
    @_template ||= EmailTemplate.find(params[:etid])
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
