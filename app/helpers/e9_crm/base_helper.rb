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
    link_to("Edit", edit_polymorphic_path(record))
  end

  def crm_delete_resource_link(record, opts = {})
    link_to("Destroy", polymorphic_path(record), :confirm => 'Are you sure?', :method => :delete)
  end

  def crm_show_resource_link(record, opts = {})
    link_to("View", polymorphic_path(record))
  end

  def crm_new_resource_link(klass)
    link_to("New #{klass.model_name.human}", new_polymorphic_path(klass))
  end

  def link_to_contact_search(attribute, query, text = nil)
    link_to(text || query, contacts_path(attribute => query), :class => "contact-search contact-#{attribute.to_s.dasherize}-search")
  end

  def email_template_select_options
    options_for_select( EmailTemplate.order('name').map {|e| [e.name, e.id] })
  end

  ##
  # Field maps
  #
  
  def records_table_field_map_for_class(klass, base_class = true)
    klass = klass.base_class if base_class
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

  def link_to_add_record_attribute(association_name)
    link_to(
      t(:add_record_attribute, :scope => :e9_crm), 
      'javascript:;', 
      :class => 'add-nested-association', 
      'data-association' => association_name
    )
  end

  def link_to_destroy_record_attribute
    link_to(
      t(:destroy_record_attribute, :scope => :e9_crm), 
      'javascript:;', 
      :class => 'destroy-nested-association'
    )
  end

  def render_record_attribute_association(association_name, form, options = {})
    options.symbolize_keys!

    association = resource.send(association_name)

    unless association.empty?
      form.fields_for(association_name) do |f|
        concat record_attribute_template(association_name, f, options)
      end
    end
  end

  def record_attribute_template(association_name, builder, options = {})
    options.symbolize_keys!

    render({
      :partial => options[:partial] || "e9_crm/record_attributes/#{association_name.to_s.singularize}",
      :locals => { :f => builder }
    })
  end

  def build_associated_resource(association_name)
    params_method = "#{association_name}_build_parameters"
    build_params = resource_class.send(params_method) if resource_class.respond_to?(params_method)
    resource.send(association_name).build(build_params || {})
  end

end
