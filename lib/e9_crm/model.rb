module E9Crm
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :contact

      has_many :tracking_cookies, :class_name => 'TrackingCookie'
      has_many :page_views, :through => :tracking_cookies

      after_create :create_associated_contact
    end

    protected

      def create_associated_contact
        self.contact ||= Contact.create(:email => self.email, :first_name => self.first_name)
      end
  end
end
