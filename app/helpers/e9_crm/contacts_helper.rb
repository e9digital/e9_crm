module E9Crm::ContactsHelper

  def link_to_contact_search(attribute, query, text = nil)
    link_to(text || query, contacts_path(attribute => query), :class => "contact-search contact-#{attribute.to_s.dasherize}-search")
  end

  def contact_email_template_select_options
    options_for_select( EmailTemplate.order('name').map {|e| [e.name, e.id] })
  end

  def contact_newsletter_select_options
    options_for_select( UserEmail.pending.order('name').map {|e| [e.name, e.id] })
  end

  def records_table_field_map_for_contact
    {
      :fields => { 
        :avatar => proc {|r| "<img src=\"#{r.avatar_url}\" alt=\"Avatar for #{r.name}\" />".html_safe  },
        :details => proc {|r| render('details', :record => r) }
      },

      :links => proc {|r|
        [link_to_show_resource(r), link_to_edit_resource(r), link_to_destroy_resource(r)]
      }
    }
  end
end
