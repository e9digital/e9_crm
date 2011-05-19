# A company record, mainly an organizational tool for Contacts
#
class Company < ActiveRecord::Base
  include E9Rails::ActiveRecord::AttributeSearchable
end
