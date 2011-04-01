class E9Crm::ContactEmailsController < E9Crm::ResourcesController
  defaults

  respond_to :js, :html

  def create
    create! do |success, failure|
      success.html { redirect_to :admin_sent_email }
      success.js { head :ok }
    end
  end

  protected

  def build_resource
    get_resource_ivar || begin
      object = if params[resource_instance_name]
        ContactEmail.new(params[resource_instance_name] || {})
      else
        ContactEmail.new_from_template(template, :from_email => current_user.email, :user_ids => params[:uids])
      end

      # we set the user_ids.blank? error right away signifiying a problem, 
      # as the record won't be valid if the user_ids weren't passed in params
      if object.user_ids.blank?
        object.errors.add(:user_ids, :blank)
      end

      set_resource_ivar(object)
    end
  end

  # throw record_not_found if there's no template.  #new requires email_template_id
  # be passed in params (and also user_ids)
  def template
    @_template ||= EmailTemplate.find(params[:etid])
  end
end
