module E9Crm
  module TrackingController
    extend ActiveSupport::Concern

    included do
      before_filter :check_for_new_session 
      after_filter  :track_page_view
    end

    protected 
      def check_for_new_session
        if request.session_options[:id].blank?
          E9Crm.log("No session found, page view will increment campaign counter cache")
          @_should_cache = true
        end
      end

      def track_page_view
        @_page_view ||= tracking_cookie.page_views.create({
          :request_path => request.fullpath,
          :user_agent   => request.user_agent,
          :referer      => request.referer,
          :remote_ip    => request.remote_ip,
          :session      => request.session_options[:id],
          :campaign     => tracking_campaign,
          :new_visit    => session[:new_visit].present?,
          :should_cache => !!@_should_cache
        })
      end

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

              if current_user && !@_tracking_cookie.user_id?
                E9Crm.log("Cookie user (#{@_tracking_cookie.user_id}) not current_user (#{current_user.id}), changing...")
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

      def tracking_campaign
        @_tracking_campaign ||= tracking_cookie.code.presence && Campaign.find_by_code(tracking_cookie.code) || Campaign.default
      end

  end
end
