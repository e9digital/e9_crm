module E9Crm
  #
  # This module is included into all controllers and makes available the current +tracking_cookie+
  # and +tracking_campaign+ as controller and helper methods
  #
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :tracking_cookie, :tracking_campaign

      prepend_before_filter do
        E9Crm.log("E9Crm controller request")
      end

      alias :liquid_env_without_crm :liquid_env

      def liquid_env
        liquid_env_without_crm.tap do |env|
          env[:campaign] = tracking_campaign
        end
      end
    end

    protected

    #
    # Attempts to get the Campaign associated with the loaded tracking cookie, and will
    # install a tracking cookie first if one is not found.
    #
    # Falls back the the default campaign (typically No Campaign) if the tracking cookie
    # is not associated with a campaign.
    #
    def tracking_campaign
      @_tracking_campaign ||= begin
        tracking_cookie.code.present? && Campaign.find_by_code(tracking_cookie.code) || Campaign.default
      end
    end

    #
    # Loads or installs the tracking cookie
    #
    def tracking_cookie
      @_tracking_cookie ||= begin
        E9Crm.log "Begin load or install cookie: cookie_name[#{E9Crm.cookie_name}] query_param[#{E9Crm.query_param}]"

        code = params.delete(E9Crm.query_param)

        if hid = cookies[E9Crm.cookie_name]
          E9Crm.log("Installed cookie found: hid(#{hid})")
          @_tracking_cookie = TrackingCookie.find_by_hid(hid)

          unless @_tracking_cookie
            # This should only happen in developemnt, as it means the cookie has been
            # installed then removed from the database.
            E9Crm.log("Installed cookie's hash id does not match any stored cookies!")
          end
        end

        E9Crm.log(@_tracking_cookie ? "Cookie loaded: (#{E9Crm.cookie_name} : #{@_tracking_cookie.hid})" : "Cookie not found")

        if @_tracking_cookie
          if current_user && @_tracking_cookie.user_id? && @_tracking_cookie.user_id != current_user.id
            E9Crm.log "Tracking user_id not matched: found(#{@_tracking_cookie.user_id}), current(#{current_user.id}"
            @_tracking_cookie = nil
          else
            attrs = {}

            if current_user && @_tracking_cookie.user_id.nil?
              E9Crm.log("Cookie has no user, setting as current_user (#{current_user.id})")
              attrs[:user] = current_user
            end

            if code.present? && code != @_tracking_cookie.code && Campaign.find_by_code(code)
              E9Crm.log "Code present and cookie code(#{@_tracking_cookie.code}) does not match (#{code}), changing..."
              attrs[:code] = code

              E9Crm.log "Cookie marked as new"
              session[:new_visit] = true
            end

            E9Crm.log(attrs.blank? ? "Cookie unchanged, no update" : "Cookie changed, new attrs: #{attrs.inspect}")
            @_tracking_cookie.update_attributes(attrs) unless attrs.blank?
          end
        end

        @_tracking_cookie ||= begin
          session[:new_visit] = true

          TrackingCookie.create(:code => code, :user => current_user).tap do |cookie|
            E9Crm.log "Installing new cookie (#{E9Crm.cookie_name} : #{cookie.hid})"
            cookies.permanent[E9Crm.cookie_name] = cookie.hid
          end
        end

        E9Crm.log("Final Cookie : #{@_tracking_cookie.inspect}")

        @_tracking_cookie
      end
    end
  end
end
