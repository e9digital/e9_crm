module E9Crm::Rack
  #
  # Returns contacts and joins their primary user for their email if it exists,
  # and will return a string like "firstname lastname (email)".  If for whatever
  # reason the contact has no primary user, it will drop the email.
  #
  class ContactAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/contacts/
        params = Rack::Request.new(env).params
        
        if query = params['query'] || params['term']
          relation = 
            Contact.any_attrs_like('first_name', 'last_name', query, :matcher => '%s%%').
              limit(params['limit'] || DEFAULT_LIMIT).
              joins("LEFT JOIN users on users.contact_id = contacts.id").
              where(%{users.options REGEXP "primary: [\\"']?true" OR users.options IS NULL}).
              select('contacts.id id, contacts.first_name first_name, contacts.last_name last_name, users.email email').
              order('contacts.first_name ASC')

          if params['except'] && (except = params['except'].scan(/(\d+),?/)) && !except.empty?
            relation = relation.where( Contact.arel_table[:id].not_in(except.flatten) )
          end

          contacts = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Contact Autocomplete').map do |row|
            name = row.values_at('first_name', 'last_name').join(' ').strip
            name << " (#{row['email']})" if row['email']
            { :label => name, :value => name, :id => row['id'] }
          end
        else
          contacts = []
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "no-cache"}, [contacts.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
