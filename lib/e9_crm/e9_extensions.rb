module E9Crm
  #
  # Extends E9Base's Email to attempt to embed the Contact
  # for the recipient in the liquid template arguments.
  #
  module Email
    extend ActiveSupport::Concern

    included do
      def locals_with_contact
        default_locals.merge({
          :contact => recipient.try(:contact)
        })
      end

      alias :default_locals :this_locals
      alias :this_locals :locals_with_contact
    end
  end
end
