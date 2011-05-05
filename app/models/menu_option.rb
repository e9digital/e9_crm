# A simple class to manage menu options, usable by other classes to build their menus.
#
class MenuOption < ActiveRecord::Base
  KEYS = [
    'Deal Category',
    'Email',
    'Instant Messaging Handle',
    'Phone Number',
    'Task Category',
    'Task Status',
    'Website'
  ].freeze

  validates :value, :presence  => true
  validates :key,   :presence  => true, :inclusion => { :in => KEYS, :allow_blank => true }

  acts_as_list :scope => 'menu_options.key = \"#{key}\"'

  scope :fetch, lambda {|key| where(:key => key) }

  ##
  # A direct SQL selection of values for a given key
  #
  #   MenuOption.fetch('Email') #=> ['Personal','Work']
  #
  # === Parameters
  #
  # [key (String)] The key for the assocated menu options.
  #
  def self.fetch_values(key)
    connection.send(:select_values, fetch(key).order(:position).project('value').to_sql, 'Menu Option Select')
  end
end
