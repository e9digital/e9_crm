module E9Crm::Rack
  #
  # Returns contacts and joins their primary user for their email if it exists,
  # and will return a string like "firstname lastname (email)".  If for whatever
  # reason the contact has no primary user, it will drop the email.
  #
  class EmailCampaignAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      params = Rack::Request.new(env).params
      
      if term = params['term']
        relation = EmailCampaign.
                     select('name, code').
                     limit(params['limit'] || DEFAULT_LIMIT).
                     attr_like(:code, term, :matcher => '%s%%')

        json = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Email Campaign Autocomplete').map do |row|
          { :label => "#{row['code']} - #{row['name']}", :value => row['code'] }
        end.to_json
      else
        json = []
      end

      [200, {"Content-Type" => "application/json", "Cache-Control" => "no-cache"}, [json]]
    end
  end
end
