class E9Crm::ContactMergesController < E9Crm::BaseController
  before_filter :build_resources

  def create
    @contact_a.attributes = params[:contact]
    @contact_a.avatar = @contact_b.avatar if params[:contact_avatar] == 'b'

    if @contact_a.merge_and_destroy!(@contact_b)
      redirect_to @contact_a
    else
      render :new
    end
  end

  protected

  def build_resources
    @contact_a ||= Contact.find(params[:contact_a_id])
    @contact_b ||= Contact.find(params[:contact_b_id])
    @contact   ||= Contact.new
  end
end
