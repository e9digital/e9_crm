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
                    :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }
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

module E9Crm
  #
  # Fairly straightforward hack to allow e9_crm views to inherit from resources.
  # If a missing template error is raised by a view looking for a template prefixed with
  # "e9_crm", redirect the lookup to "e9_crm/resources"
  #
  # This would be worth looking into further but inherited templates are a feature coming 
  # up in Rails anyway.
  #

  module ActionView
    extend ActiveSupport::Concern

    included do
      def self.process_view_paths(value)
        value.is_a?(::E9Crm::ActionView::PathSet) ?
          value.dup : ::E9Crm::ActionView::PathSet.new(Array.wrap(value))
      end
    end
    
    class PathSet < ::ActionView::PathSet
      def find(path, prefix = nil, partial = false, details = {}, key = nil)
        super
      rescue ::ActionView::MissingTemplate
        raise $! unless prefix =~ /^e9_crm/
        super(path, "e9_crm/resources", partial, details, key)
      end
    end
  end
end

ActionView::Base.send(:include, E9Crm::ActionView)
