module E9Crm::ContactsHelper

  def contact_tags
    @_contact_tags ||= begin 
      relation = Tagging.joins(:tag).select('distinct tags.name')
                        .where(:context => E9Tags.escape_context('users*'))

      Tagging.connection.send(:select_values, relation.to_sql, 'Contact Tags Select')
    end
  end

  def company_select_options
    options = Company.select("companies.name, companies.id").ordered.all.map {|c| [c.name, c.id] }
    options.unshift(['Any Company', nil])
    options_for_select(options, params[:company])
  end

  def link_to_google(query, opts = {})
    return unless query.present?

    opts.symbolize_keys!
    opts.reverse_merge!({
      :base_url => 'http://google.com/search?q=%s', 
      :exact => true,
      :text => :search
    })

    opts[:text] = I18n.t(opts[:text]) if opts[:text].is_a?(Symbol)

    query = query.to_s
    query = "\"#{query}\"" if query =~ /\s/ && opts[:exact]
    query = CGI.escape(query)
    link_to opts[:text], opts[:base_url] % query, :rel => 'nofollow external'
  end

  def google_search_link(query, opts = {})
    link_to_google query, opts
  end

  def google_news_link(query, opts = {})
    link_to_google query, opts.merge(:text => :news, :base_url => "http://news.google.com/news/search?q=%s")
  end

  def google_maps_link(query, opts = {})
    link_to_google query, opts.merge(:text => :map, :exact => false, :base_url => "http://maps.google.com/maps?q=%s")
  end

  def contact_simple_format(text)
    auto_link(
      simple_format(text), 
      :html => { :rel => 'external nofollow' }, 
      :link => :urls
    )
  end

  def link_to_contact_search(attribute, query, text = nil)
    link_to(text || query, contacts_path(attribute => query), :class => "contact-search contact-#{attribute.to_s.dasherize}-search")
  end

  def contact_tag_list(tags)
    tags.map {|tag| link_to_contact_search(:tagged, [tag], tag) }.join(', ').html_safe
  end

  def contact_newsletter_select_tag
    options = UserEmail.pending.order('name').map {|e| [e.name, e.id] }
    #select_tag 'eid', options_for_select( options.presence || [['n/a', nil]] )
    select_tag 'eid', options_for_select(options) if options.present?
  end

  def contact_email_template_select_tag
    options = EmailTemplate.order('name').map {|e| [e.name, e.id] }
    #select_tag 'etid', options_for_select( options.presence || [['n/a', nil]] )
    select_tag 'etid', options_for_select(options) if options.present?
  end

  def contact_user_subscribed_to_newsletter?(user)
    @_newsletter ||= MailingList.newsletter
    @_newsletter && user.subscription_ids.include?(@_newsletter.id)
  end

  def records_table_field_map_for_contact
    {
      :fields => { 
        :avatar => proc {|r| link_to("<img src=\"#{r.avatar_url}\" alt=\"Avatar for #{r.name}\" />".html_safe, contact_path(r)) },
        :details => proc {|r| render('details', :record => r) }
      },

      :links => proc {|r| [
        link_to_show_resource(r), 
        link_to_edit_resource(r), 
        link_to_destroy_resource(r)
      ]}
    }
  end
end
