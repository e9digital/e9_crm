class NewsletterSubscriptionOffer < SubscriptionOffer
  def self.mailing_lists
    [::MailingList.newsletter]
  end
end
