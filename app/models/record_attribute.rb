require 'ostruct'

class RecordAttribute < ActiveRecord::Base
  include E9Rails::ActiveRecord::STI

  belongs_to :record, :polymorphic => true

  serialize :options

  class_inheritable_accessor :options_parameters
  self.options_parameters = []

  class_inheritable_accessor :options_class
  self.options_class = Class.new(Hash) {
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    class_inheritable_accessor :lookup_ancestors

    class << self
      def name; 'Options' end
      def i18n_scope; :activerecord end
    end

    def initialize(hash, base)
      merge!(hash)
      @base = base
      class << self; self; end.class_eval do
        hash.each do |k, v|
          define_method(k) { self[k] }
          define_method("#{k}=") do |v| 
            self[k] = v
            @base.options = Hash[self]
            self[k]
          end
        end
      end
    end
  }
  self.options_class.lookup_ancestors = lookup_ancestors

  def options=(hash={})
    write_attribute(:options, hash)
  end

  def options
    self.class.options_class.new( (read_attribute(:options) || {}).reverse_merge(Hash[options_parameters.zip([nil])]), self)
  end

  def to_s
    value
  end
end
