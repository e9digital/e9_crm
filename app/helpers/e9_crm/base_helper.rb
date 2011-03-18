module E9Crm::BaseHelper

  ##
  # Util
  #

  def html_concat(*chunks)
    ''.html_safe.tap do |html|
      chunks.each {|chunk| html.safe_concat(chunk) }
    end
  end

  def crm_edit_resource_link(record, opts = {})
    link_to("Edit", edit_resource_path(record))
  end

  def crm_delete_resource_link(record, opts = {})
    link_to("Destroy", resource_path(record), :confirm => 'Are you sure?', :method => :delete)
  end

  def crm_show_resource_link(record, opts = {})
    link_to("View", resource_path(record))
  end

  def link_to_contact_search(attribute, query, text = nil)
    link_to(text || query, contacts_path(attribute => query), :class => "contact-search contact-#{attribute.to_s.dasherize}-search")
  end

  ##
  # Field maps
  #
  
  def records_table_field_map_for_class(klass)
    if respond_to?(method_name = "records_table_field_map_for_#{klass.name.underscore}")
      send(method_name)
    else
      { :id => nil }
    end
  end

  def records_table_field_map_for_campaign
    { 
      :type => nil, 
      :name => nil, 
      :code => nil, 
      :affiliate_fee => proc {|r| v = r.affiliate_fee; Money === v ? v : 'n/a' },  
      :sales_fee => nil, 
      :status => proc {|r| resource_class.human_attribute_name(Campaign::Status::VALUES[r.status]) } 
    }
  end

  def records_table_field_map_for_contact
    { 
      :avatar => proc {|r| },
      :details => proc {|r| render('details', :record => r) }
    }
  end

  ##
  # Links
  #

  def records_table_links_for_record(record)
    if respond_to?(method_name = "records_table_links_for_#{record.class.name.underscore}")
      send(method_name, record)
    else
      html_concat(crm_edit_resource_link(record), crm_delete_resource_link(record))
    end
  end

  def records_table_links_for_contact(record)
    html_concat(crm_show_resource_link(record), crm_edit_resource_link(record), crm_delete_resource_link(record))
  end
end
