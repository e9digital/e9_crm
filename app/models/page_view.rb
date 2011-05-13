# A visit to the site
# 
# Page views belong to a tracking cookie, from which it derives its
# campaign code, and whether or not it is a "new visit" for the given
# campaign code.
#
# === Also stored from the request:
#
# [request_path] The full request path
# [user_agent]   The request user agent
# [referer]      The request referer if it exists
# [remote_ip]    The originating ip address of the request
# [session]      The session id of the request
#
class PageView < ActiveRecord::Base
  belongs_to :tracking_cookie

  belongs_to :campaign, :inverse_of => :page_views
  has_one :user, :through => :tracking_cookie

  attr_accessor :should_cache 

  after_create :increment_campaign_visit_cache, :if => '!!should_cache'

  scope :by_user, lambda {|*users| 
    users.flatten!
    users.map! &:to_param
    joins(:tracking_cookie).where(TrackingCookie.arel_table[:user_id].send *(users.length == 1 ? [:eq, users.pop] : [:in, users]))
  }

  scope :by_campaign, lambda {|*campaigns| 
    campaigns.flatten!
    campaigns.map! &:to_param
    where(arel_table[:campaign_id].send *(campaigns.length == 1 ? [:eq, campaigns.pop] : [:in, campaigns]))
  }

  scope :new_visits,    lambda {|v=true| where(:new_visit => v) }
  scope :repeat_visits, lambda { new_visits(false) }
  scope :from_time,     lambda {|*args| args.flatten!; for_time_range(args.shift, nil, args.extract_options!) }
  scope :until_time,    lambda {|*args| args.flatten!; for_time_range(nil, args.shift, args.extract_options!) }

  scope :for_time_range, lambda {|*args|
    opts = args.extract_options!

    args.flatten!

    # try to determine a datetime from each arg, skipping #to_time on passed strings because
    # it doesn't handle everything DateTime.parse can, e.g. 'yyyy/mm'
    args.map! do |t| 
      t.presence and 

        # handle string years 2010, etc.
        t.is_a?(String) && /^\d{4}$/.match(t) && Date.civil(t.to_i) ||

        # handle Time etc. (String#to_time doesn't handle yyyy/mm properly)
        !t.is_a?(String) && t.respond_to?(:to_time) && t.to_time || 

        # try to parse it
        DateTime.parse(t) rescue nil
    end

    time_column = opts[:column] || :created_at

    if !args.any?
      where('1=0')
    elsif args.all?
      where(time_column => args[0]..args[1])
    elsif args[0]
      where(arel_table[time_column].gteq(args[0]))
    else
      where(arel_table[time_column].lteq(args[1]))
    end
  }

  delegate :name, :code, :to => :campaign, :prefix => true, :allow_nil => true

  protected

  def increment_campaign_visit_cache
    Campaign.increment_counter(new_visit ? :new_visits : :repeat_visits, campaign_id)
  end
end
