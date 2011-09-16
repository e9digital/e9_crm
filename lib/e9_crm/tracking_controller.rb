module E9Crm
  module TrackingController
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :check_for_new_session 
      after_filter  :track_page_view

      prepend_before_filter do
        E9Crm.log("E9Crm tracking controller request")
      end
    end

    protected 

    #
    # Checks to see if our session is new (a first request).  During such a call 
    # the session id has not been set yet.
    #
    # This is useful when determining whether or not the page view (created afterwards)
    # should increment the counter cache for its associated Campaign, as this should
    # only happen once per session.
    #
    def check_for_new_session
      if request.session_options[:id].blank? && request.get?
        E9Crm.log("No session found, page view will increment campaign counter cache")
        @_should_cache = true
      end

      E9Crm.log("session id: #{request.session_options[:id]}")
      E9Crm.log("session get?: #{request.get?}")
    end

    #
    # Track a page view and associate it with the loaded cookie.
    #
    # === Notable paramters
    #
    # [:new_visit]    This is stored in the session during tracking cookie creation
    #                 if the tracking cookie is either new, or changing campaigns
    #                 because a user is visiting on a different code.
    #
    # [:campaign]     The campaign associated with the tracking cookie or the default
    #                 campaign (typically the NoCampaign record)
    #
    # [:should_cache] Whether or not this page view should increment the page view
    #                 count for it's associated page.  This should only happen once
    #                 per session and for this reason, is only true on sessionless
    #                 (new) requests.  This is determined by looking for a session id
    #                 during the before filter, as in the after filter the session id
    #                 has been assigned.
    #
    def track_page_view
      if request.get?
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
    end
  end
end
