module E9Crm::DealsHelper
  def records_table_field_map_for_deal
    {
      :fields => { 
        :created_at => nil,
        :offer => nil,
        :campaign => nil
      },

      :links => proc {|r|
        []
      }
    }
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
