module E9Crm::BaseHelper

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

  def sortable_controller?
    @_sortable_controller ||= controller.class.ancestors.member?(E9Rails::Controllers::Sortable)
  end
end
