module E9Crm
  module Model
    extend ActiveSupport::Concern
    include E9Rails::ActiveRecord::InheritableOptions

    included do
      belongs_to :contact

      self.options_parameters = [:type, :primary]

      class_inheritable_accessor :email_types
      self.email_types = %w(Home Work Other)

      has_many :tracking_cookies, :class_name => 'TrackingCookie'
      has_many :page_views, :through => :tracking_cookies

      before_save :set_as_primary_if_peerless
      after_create :create_contact
      after_destroy :cleanup_contact
    end

    def primary?
      # NOTE this is probably always "true" in the current impl
      ["true", 1, '1', true].member?(options.primary)
    end

    protected

      def create_contact_parameters
        {
          :first_name => self.first_name,
          :last_name => self.last_name
        }
      end

      def set_as_primary_if_peerless
        if contact.blank? || contact.users.primary.blank?
          Rails.logger.error("***********************************")
          Rails.logger.error("USERS #{contact.users.inspect}")
          Rails.logger.error("OPTIONS #{contact.users.map(&:options)}")
          Rails.logger.error("***********************************")
          self.options.primary = true
        end
      end

      def create_contact
        unless contact.present?
          create_contact(create_contact_parameters)
        end
      end

      def cleanup_contact
        contact.users.reset_primary! if contact
      end

  end
end
