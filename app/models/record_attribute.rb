# An arbitrary 'attribute' attachable to records.  
#
# Gets support for arbitrary options via InheritableOptions.  By default it 
# has one option, +type+, but subclasses could extend for further options by
# overwriting +options_parameters+.
#
# By default, the +type+ options are managed via the +MenuOption+ class.
#
class RecordAttribute < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI
  include E9Rails::ActiveRecord::AttributeSearchable
  include E9Rails::ActiveRecord::InheritableOptions
  
  self.options_parameters = [:type]

  belongs_to :record, :polymorphic => true

  ##
  # Looks up the available +types+ for this attribute by fetching a 
  # titleized version of the class name from +MenuOption+.
  #
  # e.g.
  #   
  #   PhoneNumberAttribute.types
  #
  # is equivalent to:
  #
  #   MenuOption.fetch_values('Phone Number')
  #
  def self.types
    if name =~ /^(\w+)Attribute$/ 
      MenuOption.fetch_values($1.titleize)
    else 
      []
    end
  end

  def to_s
    options.type ? "#{value} (#{options.type})" : value
  end
end
