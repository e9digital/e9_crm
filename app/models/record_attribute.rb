class RecordAttribute < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI
  include E9Rails::ActiveRecord::AttributeSearchable
  include E9Rails::ActiveRecord::InheritableOptions
  
  self.options_parameters = [:type]

  def self.subclasses
    [ AddressAttribute, InstantMessagingHandleAttribute, PhoneNumberAttribute, WebsiteAttribute ]
  end

  belongs_to :record, :polymorphic => true

  class_inheritable_accessor :types
  self.types = []

  def to_s
    options.type ? "#{value} (#{options.type})" : value
  end
end
