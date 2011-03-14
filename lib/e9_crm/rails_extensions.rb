require 'active_record/base'
require 'action_view/base'

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
