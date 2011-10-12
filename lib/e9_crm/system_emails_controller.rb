module E9Crm
  module SystemEmailsController
    extend ActiveSupport::Concern

    included do
      alias :prepare_email_args_without_crm :prepare_email_args

      def prepare_email_args
        args    = prepare_email_args_without_crm.dup
        options = args.extract_options!

        if resource.try(:identifier) == Offer::Identifiers::CONVERSION_EMAIL
          offer = Offer.new(:name => 'TEST OFFER')
          lead  = Deal.new(:offer      => offer,
                           :lead_email => 'LEAD_EMAIL@example.com',
                           :lead_name  => 'LEAD_NAME',
                           :info       => 'Some Info',
                           :created_at => DateTime.now)

          options.merge! :offer => offer, :lead => lead
        end

        (args << options)
      end
    end
  end
end
