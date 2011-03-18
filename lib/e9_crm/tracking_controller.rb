module E9Crm
  #
  # NOTE this module depends on #current_user being implemented
  #
  module TrackingController
    extend ActiveSupport::Concern

    included { before_filter :track_page_view }

    protected 

    def track_page_view
      _load_or_install_tracking_cookie

      @_page_view ||= @_tracking_cookie.page_views.create({
        :request_path => request.fullpath,
        :user_agent   => request.user_agent,
        :referer      => request.referer,
        :remote_ip    => request.remote_ip,
        :session      => request.session_options[:id],
        :code         => @_tracking_cookie.code,
        :new_visit    => !!@_tracking_cookie.new_visit
      })
    end

    private

    def _load_or_install_tracking_cookie
      @_tracking_cookie ||= begin
        E9Crm.log "Begin load or install cookie: cookie_name[#{E9Crm.cookie_name}] query_param[#{E9Crm.query_param}]"

        code = params.delete(E9Crm.query_param)
        tcn  = E9Crm.cookie_name

        if hid = cookies[tcn]
          E9Crm.log("Installed cookie found: hid(#{hid})")
          @_tracking_cookie = TrackingCookie.find_by_hid(hid)
        end

        E9Crm.log(@_tracking_cookie ? "Cookie loaded: (#{tcn} : #{@_tracking_cookie.hid})" : "Cookie not found")

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

            if code.present? && code != @_tracking_cookie.code
              E9Crm.log "Code present and cookie code(#{@_tracking_cookie.code}) does not match (#{code}), changing..."
              attrs[:code] = code
              E9Crm.log "Cookie marked as new"
              @_tracking_cookie.new_visit = true
            end

            E9Crm.log(attrs.blank? ? "Cookie unchanged, no update" : "Cookie changed, new attrs: #{attrs.inspect}")
            @_tracking_cookie.update_attributes(attrs) unless attrs.blank?
          end
        end

        @_tracking_cookie ||= begin
          TrackingCookie.create(:code => code, :user => current_user).tap do |cookie|
            E9Crm.log "Installing new cookie (#{tcn} : #{cookie.hid})"
            cookies.permanent[tcn] = cookie.hid
            E9Crm.log "Cookie marked as new"
            cookie.new_visit = true
          end
        end

        E9Crm.log("Final Cookie : #{@_tracking_cookie.inspect}")

        @_tracking_cookie
      end
    end
  end
end
