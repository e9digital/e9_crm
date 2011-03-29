class E9Crm::ContactMergesController < E9Crm::BaseController
  before_filter :build_resources

  def create
    if @contact.update_attributes(params[:contact])

    end
  end

  protected

  def build_resources
    @contact   ||= Contact.new
    @contact_a ||= Contact.find(params[:contact_a_id])
    @contact_b ||= Contact.find(params[:contact_b_id])
  end
end
