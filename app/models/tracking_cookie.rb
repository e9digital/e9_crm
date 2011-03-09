require 'digest/md5'

class TrackingCookie < ActiveRecord::Base
  belongs_to :user
  has_many :page_views
  after_save :generate_hid, :on => :create

  attr_accessor :new_visit

  protected

  def generate_hid
    unless hid.present?
      update_attribute :hid, Digest::MD5.hexdigest("#{id}//#{DateTime.now}")
    end
  end
end
