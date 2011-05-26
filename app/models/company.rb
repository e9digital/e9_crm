# A company record, mainly an organizational tool for Contacts
#
class Company < ActiveRecord::Base
  include E9Rails::ActiveRecord::AttributeSearchable

  has_many :contacts, :dependent => :restrict

  validates :name, :presence   => true, :uniqueness => { :allow_blank => true, :case_sensitive => false }

end
