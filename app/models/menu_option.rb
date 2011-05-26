# A simple class to manage menu options, usable by other classes to build their menus.
#
class MenuOption < ActiveRecord::Base
  KEYS = [
    #'Task Category',
    #'Task Status',
    'Address',
    'Deal Category',
    'Email',
    'Instant Messaging Handle',
    'Phone Number',
    'Website'
  ].freeze

  validates :value, :presence  => true
  validates :key,   :presence  => true, :inclusion => { :in => KEYS, :allow_blank => true }

  acts_as_list :scope => 'menu_options.key = \"#{key}\"'

  scope :options_for, lambda {|key| where(:key => key).order('menu_options.position ASC') }

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
    connection.send(:select_values, options_for(key).order(:position).project('value').to_sql, 'Menu Option Select')
  end

  def to_s
    value
  end
end
