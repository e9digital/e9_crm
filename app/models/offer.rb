# A +Renderable+ which "offers" the user something.  Responses to these
# offers are tracked as +Leads+
#
class Offer < Renderable
  include E9Rails::ActiveRecord::STI
  include E9Rails::ActiveRecord::Initialization
  include E9Rails::ActiveRecord::InheritableOptions

  has_many :deals, :inverse_of => :offer
  has_many :leads, :class_name => 'Deal', :conditions => ["deals.status = ?", Deal::Status::Lead]

  validates :conversion_alert_email, :email => { :allow_blank => true }

  mount_uploader :file, FileUploader

  self.delegate_options_methods = true
  self.options_parameters = [
    :submit_button_text,
    :success_alert_text,
    :success_page_text,
    :download_link_text,
    :conversion_alert_email,
    :custom_form_html
  ]

  class << self
    def conversion_email
      SystemEmail.find_by_identifier(Identifiers::CONVERSION_EMAIL)
    end

    def page
      SystemPage.find_by_identifier(Identifiers::PAGE)
    end

    def partial_path
      'e9_crm/offers/offer'
    end

    def element
      'offer'
    end
  end

  def to_s
    name
  end


  protected

    def _assign_initialization_defaults
      self.submit_button_text ||= 'Submit!'
      self.download_link_text ||= 'Click to download your file'
      self.success_page_text  ||= 'Thank you!'
    end

  module Identifiers
    CONVERSION_EMAIL = 'offer_conversion_email'
    PAGE             = 'offer_page'
  end
end
