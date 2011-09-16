# A +Renderable+ which "offers" the user something.  Responses to these
# offers are tracked as +Leads+
#
class Offer < Renderable
  include E9Rails::ActiveRecord::STI
  include E9Rails::ActiveRecord::Initialization
  include E9Rails::ActiveRecord::InheritableOptions

  has_many :deals, :inverse_of => :offer, :dependent => :restrict
  has_many :leads, :class_name => 'Deal', :conditions => ["deals.status = ?", Deal::Status::Lead], :dependent => :restrict

  validates :conversion_alert_email, :email => { :allow_blank => true }

  mount_uploader :file, FileUploader

  self.delegate_options_methods = true
  self.options_parameters = [
    :submit_button_text,
    :success_page_text,
    :conversion_alert_email,
    :custom_form_html,
    :mailing_list_ids
  ]

  def has_mailing_list?(ml)
    (mailing_list_ids || []).map(&:to_s).member?(ml.id.to_s)
  end

  def mailing_lists
    @_mailing_lists ||= begin
      mailing_list_ids ? MailingList.find_all_by_id(mailing_list_ids) : []
    end
  end

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

  def to_liquid
    Drop.new(self)
  end

  protected

    def _assign_initialization_defaults
      self.submit_button_text ||= 'Submit!'
      self.success_page_text  ||= 'Thank you!'
    end

  class Drop < ::E9::Liquid::Drops::Base
    source_methods :name, :deals, :leads
  end

  module Identifiers
    CONVERSION_EMAIL = 'offer_conversion_email'
    PAGE             = 'offer_page'
  end
end
