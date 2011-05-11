# A +Renderable+ which "offers" the user something.  Responses to these
# offers are tracked as +Leads+
#
class Offer < Renderable
  has_many :deals, :inverse_of => :offer
  has_many :leads, :class_name => 'Deal', :conditions => ["deals.status = ?", Deal::Status::Lead]

  class << self
    def conversion_email
      SystemEmail.find_by_identifier(Identifiers::CONVERSION_EMAIL)
    end

    def page
      SystemPage.find_by_identifier(Identifiers::PAGE)
    end
  end

  include E9Rails::ActiveRecord::InheritableOptions
  self.delegate_options_methods = true
  self.options_parameters = [
    :submit_button_text,
    :success_alert_text,
    :download_link_text,
    :conversion_alert_email,
    :success_page_text,
    :custom_form_html
  ]

  mount_uploader :file, FileUploader

  validates :conversion_alert_email, :email => { :allow_blank => true }

  def to_s
    name
  end

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]       = self.id,
      hash[:name]     = self.name,
      hash[:template] = self.template,
      hash[:errors]   = self.errors
    end
  end

  module Identifiers
    CONVERSION_EMAIL = 'offer_conversion_email'
    PAGE             = 'offer_page'
  end
end
