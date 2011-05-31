module E9Crm::Rack
  #
  # Returns contacts and joins their primary user for their email if it exists,
  # and will return a string like "firstname lastname (email)".  If for whatever
  # reason the contact has no primary user, it will drop the email.
  #
  class CompanyAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/companies/
        params = Rack::Request.new(env).params
        
        if term = params['term']
          relation = Company.limit(params['limit'] || DEFAULT_LIMIT).select('name').attr_like('name', term, :matcher => '%s%%')

          companies = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Company Autocomplete').map do |row|
            { :label => row['name'], :value => row['name'] }
          end
        else
          companies = []
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [companies.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
