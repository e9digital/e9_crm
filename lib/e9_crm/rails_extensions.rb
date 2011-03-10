require 'active_record/base'

class ActiveRecord::Base

  #
  # Basic conversion for "money" columns using the Money class
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
