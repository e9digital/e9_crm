module E9Crm
  #
  # NOTE this module depends on #current_user being implemented
  #
  module TrackingController
    extend ActiveSupport::Concern

    included { before_filter :track_page_view }

    mattr_accessor :cookie_name
    @@cookie_name = '_e9_tc'

    mattr_accessor :query_param
    @@query_param = 'code'

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

    def log(msg)
      Rails.logger.debug("CRM: #{msg}")
    end

    def _load_or_install_tracking_cookie
      @_tracking_cookie ||= begin
        log "Begin load or install cookie: cookie_name[#{TrackingController.cookie_name}] query_param[#{TrackingController.query_param}]"

        code = params.delete(TrackingController.query_param)
        tcn  = TrackingController.cookie_name

        if hid = cookies[tcn]
          log("Installed cookie found: hid[#{hid}]")
          @_tracking_cookie = TrackingCookie.find_by_hid(hid)
        end

        log(@_tracking_cookie ? "Cookie loaded: (#{tcn} : #{@_tracking_cookie.hid})" : "Cookie not found")

        if @_tracking_cookie.present?
          attrs = {}

          if current_user && !@_tracking_cookie.user_id?
            log("Cookie user (#{@_tracking_cookie.user_id}) not current_user (#{current_user.id}), changing...")
            attrs[:user] = current_user
          end

          if code.present? && code != @_tracking_cookie.code
            log "Code present and cookie code(#{@_tracking_cookie.code}) does not match (#{code}), changing..."
            attrs[:code] = code
            log "Cookie marked as new"
            @_tracking_cookie.new_visit = true
          end

          log(attrs.blank? ? "Cookie unchanged, no update" : "Cookie changed, new attrs: #{attrs.inspect}")
          @_tracking_cookie.update_attributes(attrs) unless attrs.blank?
        end

        @_tracking_cookie ||= begin
          TrackingCookie.create(:code => code, :user => current_user).tap do |cookie|
            log "Installing new cookie (#{tcn} : #{cookie.hid})"
            cookies.permanent[tcn] = cookie.hid
            log "Cookie marked as new"
            cookie.new_visit = true
          end
        end

        log "Final Cookie : #{@_tracking_cookie.inspect}"

        @_tracking_cookie
      end
    end
  end
end
