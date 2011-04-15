module E9Crm
  module Model
    extend ActiveSupport::Concern
    include E9Rails::ActiveRecord::InheritableOptions

    included do
      belongs_to :contact

      self.options_parameters = [:type, :primary]

      class_inheritable_accessor :email_types
      self.email_types = %w(Personal Work Other)

      has_many :tracking_cookies, :class_name => 'TrackingCookie'
      has_many :page_views, :through => :tracking_cookies

      scope :primary, lambda { where(arel_table[:options].matches("%primary: true%")) }

      before_create :create_contact_if_missing
      after_destroy :cleanup_contact
    end

    def primary?
      !!options.primary
    end

    protected

      def create_contact_parameters
        {
          :first_name => self.first_name,
          :last_name => self.last_name
        }
      end

      def create_contact_if_missing
        if contact.blank?
          # when creating a contact we should assume we're the primary email
          self.options.primary = true

          create_contact(create_contact_parameters)
        end
      end

      def cleanup_contact
        # NOTE this is called after_delete, reload the contact to clear the deleted
        #      user from the contact's #users
        contact.reload.users.reset_primary! if self.primary? && contact.present?
      end

  end
end
