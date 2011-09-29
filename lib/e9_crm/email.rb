module E9Crm
  module Email
    extend ActiveSupport::Concern

    included do
      attr_accessor :contact

      def default_options_with_contact
        default_options_without_contact.merge({
          :contact => @contact || 
            default_options_without_contact[:recipient].try(:contact)
        })
      end

      alias :default_options_without_contact :default_options
      alias :default_options :default_options_with_contact
    end
  end
end
