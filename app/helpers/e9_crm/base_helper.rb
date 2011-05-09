module E9Crm::BaseHelper

  ##
  # Util
  #

  def html_concat(*chunks)
    ''.html_safe.tap do |html|
      chunks.each {|chunk| html.safe_concat("#{chunk}\n") }
    end
  end

  def link_to_contact_search(attribute, query, text = nil)
    link_to(text || query, contacts_path(attribute => query), :class => "contact-search contact-#{attribute.to_s.dasherize}-search")
  end

  def email_template_select_options
    options_for_select( EmailTemplate.order('name').map {|e| [e.name, e.id] })
  end

  def newsletter_select_options
    options_for_select( UserEmail.pending.order('name').map {|e| [e.name, e.id] })
  end

  ##
  # Field maps
  #
  
  def records_table_field_map(options = {})
    options.symbolize_keys!
    options.reverse_merge!(:class_name => resource_class.base_class.name.underscore)

    base_map = {
      :fields => { :id => nil },
      :links => proc {|r| [link_to_edit_resource(r), link_to_destroy_resource(r)] }
    }

    if respond_to?(method_name = "records_table_field_map_for_#{options[:class_name]}")
      base_map.merge! send(method_name)
    end

    base_map
  end

  def records_table_map_for_campaign
    { 
      :fields => {
        :type => nil, 
        :name => nil, 
        :code => nil, 
        :affiliate_fee => proc {|r| v = r.affiliate_fee; Money === v ? v : 'n/a' },  
        :sales_fee => nil, 
        :status => proc {|r| resource_class.human_attribute_name(Campaign::Status::VALUES[r.status]) } 
      }
    }
  end

  def records_table_field_map_for_contact
    {
      :fields => { 
        :avatar => proc {|r| },
        :details => proc {|r| render('details', :record => r) }
      },

      :links => proc {|r|
        [link_to_show_resource(r), link_to_edit_resource(r), link_to_destroy_resource(r)]
      }
    }
  end

  def records_table_field_map_for_menu_option
    { 
      :fields => {
        :position => proc { '<div class="handle">+++</div>'.html_safe },
        :value => nil,
        :key => nil
      }
    }
  end


  ##
  # Misc
  #

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

  def sortable_controller?
    @_sortable_controller ||= controller.class.ancestors.member?(E9Rails::Controllers::Sortable)
  end

end
