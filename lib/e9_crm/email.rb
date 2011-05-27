module E9Crm
  module Email
    extend ActiveSupport::Concern

    included do
      attr_accessor :contact

      def locals_with_contact
        default_locals.merge({
          :contact => @contact || recipient.try(:contact)
        })
      end

      alias :default_locals :this_locals
      alias :this_locals :locals_with_contact
    end
  end
end
