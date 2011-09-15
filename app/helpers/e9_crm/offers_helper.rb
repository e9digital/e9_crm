module E9Crm::OffersHelper
  def records_table_field_map_for_offer
    {
      :fields => { :name => nil }
    }
  end

  def offer_mailing_lists
    @_offer_mailing_lists ||= begin
      retv =  MailingList.newsletters.all
      retv << MailingList.new_content_alerts
      retv.compact
    end
  end
end
