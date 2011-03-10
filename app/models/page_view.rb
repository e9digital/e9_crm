class PageView < ActiveRecord::Base
  belongs_to :tracking_cookie
  has_one :user, :through => :tracking_cookie

  scope :new_visits,    lambda { |v=true| where(:new_visit => v) }
  scope :repeat_visits, lambda { new_visits(false) }
  scope :coded,         lambda { where(arel_table[:code].not_eq(nil)) }
  scope :uncoded,       lambda { where(:code => nil) }
end
