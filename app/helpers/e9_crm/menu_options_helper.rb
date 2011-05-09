module E9Crm::MenuOptionsHelper
  def records_table_field_map_for_menu_option
    { 
      :fields => {
        :position => proc { '<div class="handle">+++</div>'.html_safe },
        :value => nil,
        :key => nil
      }
    }
  end
end
