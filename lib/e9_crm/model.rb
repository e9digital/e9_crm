module E9Crm
  ##
  # The User model associated with a Contact.  The idea is that a Contact can be 
  # associated to many different logins/users (e.g. bob@home.com, bob@work.com).
  #
  # In the default setup the included model is treated as simply an email, and given a
  # "type" such as Personal, Work, etc.
  #
  # One and only one of these models should be considered "primary".  The designation of
  # which is handled largely by the Contact class.
  #
  module Model
    extend ActiveSupport::Concern
    include E9Rails::ActiveRecord::InheritableOptions

    included do
      belongs_to :contact, :inverse_of => :users

      has_many :tracking_cookies, :inverse_of => :user
      has_many :page_views, :through => :tracking_cookies

      self.options_parameters = [:type, :primary]

      scope :primary, lambda { where(%Q{#{table_name}.options REGEXP "primary: [\\"']?true"}) }

      before_save :create_contact_if_missing!
      after_destroy :cleanup_contact
    end

    ##
    # Is this the Contact's primary model?
    #
    def primary?
      ["true", true].member? options.primary
    end

    def create_contact_if_missing!
      if contact.blank?
        # when creating a contact we should assume we're primary
        self.options.primary = true
        create_contact(create_contact_parameters)
      end
    end

    protected

      def create_contact_parameters
        { :first_name => self.first_name, :last_name => self.last_name }
      end

      def cleanup_contact
        # NOTE this is called after_delete, reload the contact to clear the deleted
        #      user from the contact's #users
        contact.reload.users.reset_primary! if self.primary? && contact.present?
      end

    module ClassMethods
      def email_types
        MenuOption.fetch_values('Email')
      end
    end
  end
end
