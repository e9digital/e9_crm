module E9Crm
  module SystemEmailsController
    extend ActiveSupport::Concern

    included do
      alias :send_test_email_without_crm :send_test_email

      def send_test_email(email, current_user)
        if email.try(:identifier) == Offer::Identifiers::CONVERSION_EMAIL
          offer = Offer.new(:name => 'TEST OFFER')
          lead  = Deal.new(:offer      => offer,
                           :lead_email => 'LEAD_EMAIL@example.com',
                           :lead_name  => 'LEAD_NAME',
                           :info       => 'Some Info',
                           :created_at => DateTime.now)

          Offer.conversion_email.send!(current_user, {
            :offer => offer, 
            :lead => lead
          })
        else
          send_test_email_without_crm(email)
        end
      end
    end
  end
end
