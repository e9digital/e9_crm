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
      options.map! {|o| [o.titleize, o] }
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
      options = deal_contacts_array
      options.unshift ['All Responsible', nil]
      options_for_select(options)
    end
  end

  def deal_offer_select_options
    @_deal_offer_select_options ||= begin
      options = Offer.all.map {|c| [c.name, c.id] }.sort_by {|name, id| name.upcase }
      options.unshift ['Any/No Offer', nil]
      options_for_select(options)
    end
  end

  def deal_date_select_options(options = {})
    @_first_deal_date ||= Deal.order(:created_at).first.try(:created_at) || Date.today

    date, cdate = @_first_deal_date, Date.today

    sel_options = []

    if options[:type] == :until
      prefix = 'Up to '
      label = prefix + ' Now'
    elsif options[:type] == :in_month
      prefix = 'Closed in '
      label = 'Since Inception'
    else
      prefix = 'Since '
      label = prefix + ' Inception'
    end

    begin
      sel_options << [date.strftime("#{prefix}%B %Y"), date.strftime('%Y/%m')]
      date += 1.month
    end while date.year <= cdate.year && date.month <= cdate.month

    sel_options.reverse!

    sel_options.unshift([label, nil])

    options_for_select(sel_options)
  end

  def deal_contacts
    @_eligible_responsible_contacts ||= begin
      roles = E9::Roles.list.map(&:role).select {|r| r > 'user' && r < 'e9_user' }
      User.includes(:contact).for_roles(roles).all.map(&:contact).compact.sort_by {|c| c.name.upcase }
    end
  end

  def deal_contacts_array
    deal_contacts.map {|c| [c.name, c.id] }
  end

  def title_and_or_company(contact)
    [contact.title, contact.company_name].
      map(&:presence).compact.join(' at ').html_safe
  end
end
