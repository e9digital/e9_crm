module E9Crm::CampaignsHelper
  def display_campaign_fee(val)
    Money === val && val || 'n/a'
  end

  def display_campaign_code(val)
    val || 'n/a'
  end

  def campaign_type_select_options(with_all_option = true)
    options = %w( advertising affiliate email sales ).map {|t| [t.titleize, t] }
    options.unshift(['All Types', nil]) if with_all_option
    options_for_select(options)
  end

  def campaign_group_select_options
    options = CampaignGroup.select('name, id').all.map {|c| [c.name, c.id] }
    options.unshift(['All Groups', nil])
    options_for_select(options)
  end

  def campaign_active_select_options
    options = [
      ['All Statuses', nil],
      ['Active',      true],
      ['Inactive',   false]
    ]
    options_for_select(options)
  end

  ##
  # Accommodate for "NoCampaign" campaign in link
  #
  def link_to_edit_campaign(record)
    link_to_edit_campaign(record) unless record.is_a?(NoCampaign)
  end
end
