require 'active_record/base'
require 'action_view/base'

class Array
  #
  # Simple helper for array calculating averages
  #
  # Returns 0 if all array elements do not exist and respond to to_f
  #
  # NOTE nil responds to to_f but not to +, which would throw an
  #      exception on sum if nil was allowed in the array
  #
  def average
    return 0 unless length > 0 && all? {|n| n && n.respond_to?(:to_f) }
    sum / length
  end
end


#
# Money is too clever by half and attempts to deal with parsing Strings into
# currency e.g. 
#
#   "asdf 0.23 asdf".to_money #=> #<Money cents:23 currency:USD>
#
# This is problematic if you want to actually validate money as it parses most
# bogus strings to zero, so unless you want to validate > 0, most any input
# will pass validation.
#
# This silly hack prevents "asdf".to_money from parsing to 0 cents, instead
# returning itself.  The #cents method allows for our composed_of column to
# still work, simply returning self, which would fail a numericality validation.
#
require 'money'

class String
  def to_money(currency = nil)
    if match /^$|[^\$\d\.\,]/
      self
    else
      Money.parse(self, currency)
    end
  end

  def cents
    self
  end
end

class ActiveRecord::Base
  #
  # Basic conversion for "money" columns using the Money class and Rails composed_of
  #
  def self.money_columns(*column_names)
    column_names.each do |column_name|
      class_eval <<-EVAL
        composed_of :#{column_name},
                    :class_name => 'Money',
                    :mapping => %w(#{column_name} cents),
                    :converter => Proc.new {|v| v.respond_to?(:to_money) ? v.to_money : v }
      EVAL
    end
  end
end

module E9Crm
  #
  # Simple string subclass that lets you query the string against
  # a "label" it was initialized with. e.g. 
  #
  #   LabeledString.new(:omfg, 'whatever').omfg? #=> true
  #
  class LabeledString < String
    attr_reader :label

    def initialize(label, *args)
      @label = label if label.is_a?(Symbol)
      super(*args)
    end

    def method_missing(method_name, *args)
      if @label && method_name.to_s[-1,1] == '?'
        method_name.to_s[0..-2] == @label.to_s
      else
        super
      end
    end
  end
end

module ActiveModel
  class Errors
    alias :default_add :add

    # Monkeypatch add to replace the error message with a LabeledString, which
    # simply changes method missing to respond to methods ending with '?' by
    # checking to see if their label matches the method.
    #
    # This makes it easy to check an error's message for what error symbol it
    # was generated for, e.g. :invalid, by calling #invalid? on it.
    #
    # Errors#add accepts a Proc or a Symbol for message (or defaults to :invalid)
    # so this is hack isn't always useful, but for my purposes I want to know when
    # a :taken error was added to a User#email, and this is good enough.
    #
    def add(attribute, message = nil, options = {})
      default_add(attribute, message, options)

      self[attribute] << E9Crm::LabeledString.new(message, self[attribute].pop)
    end
  end
end
