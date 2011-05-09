class E9Crm::ContactMergesController < E9Crm::BaseController
  before_filter :build_resources

  def create
    if @contact_a.update_attributes(params[:contact])
      @contact_a.merge_and_destroy!(@contact_b)
      redirect_to @contact_a
    else
      render :new
    end
  end

  protected

  def build_resources
    @contact   ||= Contact.new
    @contact_a ||= Contact.find(params[:contact_a_id])

    # NOTE lets see if this works
    @contact_b ||= if params[:contact]
                     Contact.new(params[:contact])
                   else
                     Contact.find(params[:contact_b_id])
                   end
  end
end
