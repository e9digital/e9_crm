module E9Crm::BaseHelper

  def kramdown(string)
    Kramdown::Document.new(string).to_html.html_safe
  end

  alias :k :kramdown

  def help_tooltip(string)
    return <<-HTML.strip.html_safe
      <span class="help" rel="tooltip" title="#{CGI.escape_html(string)}">#{t(:inline_help_link)}</span>
    HTML
  end

  def help_label(form_or_id, key, options = {})
    options[:key] ||= :"#{key}_help"

    help_title = options.delete(:title) || resource_humanize(options.delete(:key))

    str = ''.html_safe
    str.safe_concat resource_humanize(key)
    str.safe_concat ' '
    str.safe_concat help_tooltip(help_title)

    if form_or_id.respond_to?(:label)
      form_or_id.label(key, str, options)
    else
      label_tag(form_or_id, str, options)
    end
  end

  ##
  # Field maps
  #
  
  def records_table_field_map(options = {})
    options.symbolize_keys!
    options.reverse_merge!(:class_name => resource_class.name.underscore)

    base_map = {
      :fields => { :id => nil },
      :links => lambda {|r| [link_to_edit_resource(r), link_to_destroy_resource(r)] }
    }

    method_name = "records_table_field_map_for_#{options[:class_name]}"

    if respond_to?(method_name)
      base_map.merge! send(method_name)
    end

    base_map
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

  def render_record_attribute_form(association_name, form)
    render('e9_crm/record_attributes/form_partial', {
      :form             => form,
      :association_name => association_name
    })
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

    render(
      :partial => options[:partial] || "e9_crm/record_attributes/#{association_name.to_s.singularize}",
      :locals => { :f => builder }
    )
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
