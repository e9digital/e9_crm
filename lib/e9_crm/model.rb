module E9Crm
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :contact

      has_many :tracking_cookies, :class_name => 'TrackingCookie'
      has_many :page_views, :through => :tracking_cookies

      #
      # Whenever a user is saved it should either find the
      # related contact (by email typically) or create one
      # with the default parameters
      #
      after_save :find_or_create_associated_contact

      #
      # Destroying should nullify the Contact's
      # primary_user relation but leave the Contact intact.
      #
      # Oppositely, destroying a Contact should nullify User's 
      # Contact relation, but leave the user intact.
      #
      before_destroy :remove_as_contact_primary_user
    end

    def primary_contact?
      contact.present? && contact.primary_user === self
    end

    protected

      def associated_contact_parameters
        {
          :email => self.email,
          :first_name => self.first_name
        }
      end

      def find_or_create_associated_contact
        unless contact.present?
          update_attribute(:contact, 
            Contact.find_by_email(self.email) || create_contact(associated_contact_parameters)
          )
        end
      end

      def remove_as_contact_primary_user
        if primary_contact?
          contact.reset_primary_user!(:reject => self)
        end
      end
  end
end
