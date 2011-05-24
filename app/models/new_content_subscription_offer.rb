class NewContentSubscriptionOffer < SubscriptionOffer
  def self.mailing_lists
    [::MailingList.new_content_alerts]
  end
end
