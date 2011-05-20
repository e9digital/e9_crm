module E9Crm::DealsHelper
  def deal_contact_select_options
    @_deal_contact_select_options ||= begin
      contacts = Contact.available_to_deal(resource)

      options = contacts.map {|contact| [contact.name, contact.id] }
      options.unshift ['Add Contact', nil]
      options_for_select options
    end
  end

  def deal_contact_select
    select_tag 'contacts_ids', deal_contact_select_options
  end

  def deal_status_select_options
    @_deal_status_select_options ||= begin
      options = Deal::Status::OPTIONS - %w(lead)
      options.unshift ['All Statuses', nil]
      options_for_select(options)
    end
  end

  def deal_category_select_options
    @_deal_category_select_options ||= begin
      options = MenuOption.options_for('Deal Category')
      options.unshift ['All Categories', nil]
      options_for_select(options)
    end
  end

  def deal_owner_select_options
    @_deal_owner_select_options ||= begin
      options = Contact.deal_owners.all.map {|c| [c.name, c.id] }
      options.unshift ['Any Owner', nil]
      options_for_select(options)
    end
  end

  def deal_date_select_options(ending_month = false)
    @_first_deal_date ||= Deal.order(:created_at).first.try(:created_at) || Date.today

    date, cdate = @_first_deal_date, Date.today

    options = []

    if ending_month
      prefix = 'Until'
      label = prefix + ' Now'
    else
      prefix = 'From'
      label = prefix + ' Inception'
    end

    begin
      options << [date.strftime("#{prefix} %B %Y"), date.strftime('%Y/%m')]
      date += 1.month
    end while date.year <= cdate.year && date.month <= cdate.month

    options.unshift([label, nil])

    options_for_select(options)
  end
end
