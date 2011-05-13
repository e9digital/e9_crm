require 'rails/generators'
require 'rails/generators/migration'

module E9Crm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', File.dirname(__FILE__))

      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def generate_migrations
        migration_template 'migration.rb', 'db/migrate/create_e9_crm_structure.rb'
      end

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/e9_crm.rb'
      end

      def copy_javascript
        copy_file 'javascript.js', 'public/javascripts/e9_crm.js'
      end
    end
  end
end
