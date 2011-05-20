module E9Crm::OffersHelper
  def records_table_field_map_for_offer
    {
      :fields => { 
        :name => nil,
        :type => lambda {|r| r.class.model_name.human }
      }
    }
  end

  def offer_select_options(with_all_option = true)
    options = %w(contact file_download new_content_subscription newsletter_subscription video).map {|t| [t.titleize, t] }
    options.unshift(['All Types', nil]) if with_all_option
    options_for_select(options)
  end
end
