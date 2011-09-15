module E9Crm::Rack
  class EmailAvailabilityChecker
    def self.call(env)
      @params  = Rack::Request.new(env).params
      @email   = @params['email']
      @contact = nil
      @url     = nil

      if @user = User.find_by_email(@email)
        if @contact = @user.contact
          @url = if @params['id'] && c = Contact.find_by_id(@params['id'])
            "/admin/crm/merge_contacts/#{@contact.id}/and/#{c.id}"
          else
            "/admin/crm/contacts/#{@contact.id}/edit"
          end
        end

        @body = {
          :email      => @email,
          :id         => @user.id,
          :contact_id => @contact.try(:id),
          :url        => @url
        }.to_json

        [200, {"Content-Type" => "application/json"}, [@body]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
