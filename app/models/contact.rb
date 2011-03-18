class Contact < ActiveRecord::Base
  include E9Tags::Model

  belongs_to :user
  belongs_to :company

  has_many :phone_numbers, :class_name => 'PhoneNumberAttribute', :as => :record
  has_many :instant_messaging_handles, :class_name => 'InstantMessagingHandleAttribute', :as => :record
  has_many :websites, :class_name => 'WebsiteAttribute', :as => :record
  has_many :addresses, :class_name => 'AddressAttribute', :as => :record

  scope :tagged, lambda {|tag| tagged_with(tag, :show_hidden => true) }
  scope :by_title, lambda {|val| where(:title => val) }
  scope :by_company, lambda {|val| where(:company_id => val) }

  delegate :name, :to => :company, :prefix => true, :allow_nil => true

  def name
    [first_name, last_name].join(' ')
  end
end
