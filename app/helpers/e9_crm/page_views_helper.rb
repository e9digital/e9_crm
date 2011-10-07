module E9Crm::PageViewsHelper
  def page_view_campaign_select_options
    @_page_view_campaign_select_options ||= begin
      opts = Campaign.all.map {|campaign| [campaign.name, campaign.id] }
      opts.unshift ['Any', nil]
      options_for_select(opts)
    end
  end

  def page_view_new_visit_select_options
    options_for_select([
      ['Any', nil],
      ['New Visits', true],
      ['Repeat Visits', false]
    ])
  end

  def page_view_date_select_options(options = {})
    @_first_date ||= PageView.order(:created_at).first.try(:created_at) || Date.today

    date, cdate = @_first_date, Date.today

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
end
