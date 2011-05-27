class Contact < ActiveRecord::Base
  include E9Tags::Model
  include E9Rails::ActiveRecord::AttributeSearchable
  include E9Rails::ActiveRecord::Initialization

  # necessary so contact knows its merge path
  # NOTE in the future we'll probably want to give contacts public urls and make them 'Linkable'
  include Rails.application.routes.url_helpers

  before_validation :ensure_user_references
  before_destroy :ensure_no_associated_deals

  ##
  # Associations
  #
  belongs_to :company
  has_many :owned_deals, :class_name => 'Deal', :dependent => :restrict
  has_and_belongs_to_many :associated_deals, :class_name => 'Deal'

  has_many :users, :inverse_of => :contact, :dependent => :nullify do

    ##
    # Resets the primary user on a contact
    #
    # == Parameters
    #
    # [options (Hash)] An options hash containing either the :id or :index
    #                  of the User to set as primary.  If neither is set it
    #                  will default the first User designated primary in the
    #                  list, or the first user in the list if no such user
    #                  exists.
    #
    #                  Also accepts a :save option, which will force save
    #                  the User with no validation.
    #
    def reset_primary(options = {})
      return if empty?
      options.symbolize_keys!
      options.slice!(:id, :index, :save)

      should_save = options.delete(:save)

      if options.empty?
        if p = primary.first
          options[:id] = p.id
        else
          options[:index] = 0
        end
      end

      each_with_index do |user, i|
        if options[:id]
          user.options.primary = options[:id] == user.id
        else
          user.options.primary = options[:index] == i
        end

        user.save(:validate => false) if should_save && user.options_changed?
      end
    end

    ##
    # Resets the primary User, forcing :save
    #
    def reset_primary!(options = {})
      reset_primary options.merge(:save => true)
    end

    ##
    # Clears all users of primary status, used when merging/resetting Contacts.
    # Does not force save.
    #
    def clear_primary(options = {})
      reset_primary options.merge(:index => -1)
    end

    ##
    # Clears all users of primary status, used when merging/resetting Contacts,
    # Fores save.
    #
    def clear_primary!
      clear_primary :save => true 
    end
  end
  accepts_nested_attributes_for :users, :allow_destroy => true

  def primary_user
    users.primary.first
  end

  delegate :email, :to => :primary_user, :allow_nil => true

  def page_views
    PageView.by_user(users)
  end

  has_many :record_attributes, :as => :record
  RECORD_ATTRIBUTES = %w[users phone_number_attributes instant_messaging_handle_attributes website_attributes address_attributes]
  # NOTE Mind the hack here, "users" are "attributes" but not added in this loop.  This was so the RECORD_ATTRIBUTES constant
  #      would include :users (for building the templates.js).
  RECORD_ATTRIBUTES.select {|r| r =~ /attributes$/ }.each do |association_name|
    has_many association_name.to_sym, :class_name => association_name.classify, :as => :record
    accepts_nested_attributes_for association_name.to_sym, :allow_destroy => true, :reject_if => :reject_record_attribute?
  end

  def build_all_record_attributes
    RECORD_ATTRIBUTES.each do |attr|
      params_method = "#{attr}_build_parameters"
      build_params = self.class.send(params_method) if self.class.respond_to?(params_method)
      send(attr).send(:build, build_params || {})
    end
  end

  ##
  # Validations
  #
  validates :first_name, :presence => true, :length => { :maximum => 25 }

  ##
  # Scopes
  #

  # NOTE contact#search feels terribly fragile and needs work.  
  #
  # The issue lies in the need to outer join record_attributes because the 
  # join is optional.
  #
  # We end up with multiple rows per Contact.  This could be solved
  # by a distinct select, but that breaks when we need to do things
  # like User.joins(:contact) & Contact.search("whatever")
  #
  # While it's like this, note that #search groups (hardcoded on "contacts")
  #
  scope :search, lambda {|query|
    join_sql = %{
      LEFT OUTER JOIN record_attributes 
        ON record_attributes.record_id = contacts.id
        AND record_attributes.record_type = 'Contact'
      LEFT OUTER JOIN users AS contacts_users
        ON contacts_users.contact_id = contacts.id
      LEFT OUTER JOIN companies
        ON companies.id = contacts.company_id
    }

    where_sql = any_attrs_like_scope_conditions(:first_name, :last_name, :title, query)
                  .or(RecordAttribute.attr_like_scope_condition(:value, query))
                  .or(Company.attr_like_scope_condition(:name, query))
                  .to_sql.gsub(/\s+/, ' ')

    ucond = sanitize_sql_array(['contacts_users.email like ?', "%#{query}%"])
    where_sql << " OR (#{ucond})"

    select("distinct contacts.*").joins(join_sql).where(where_sql)
  }

  scope :sales_persons, lambda { where(:status => Status::SalesPerson) }
  scope :affiliates, lambda { where(:status => Status::Affiliate) }
  scope :contacts, lambda { where(:status => Status::Contact) }
  scope :ordered, lambda { order(arel_table[:first_name].asc) }

  scope :ok_to_email, lambda { where(:ok_to_email => true) }
  scope :by_title, lambda {|val| where(:title => val) }
  scope :by_company, lambda {|val| where(:company_id => val) }
  scope :tagged, lambda {|tags| 
    if tags.present?
      tagged_with(tags, :show_hidden => true, :any => true) 
    else
      where("1=0")
    end
  }

  # NOTE for future restriction?
  scope :deal_owners, lambda { scoped }

  def self.available_to_deal(deal) 
    return all unless deal.persisted?

    sql = <<-SQL
      SELECT distinct contacts.* FROM `contacts` 
        LEFT OUTER JOIN `contacts_deals` 
          ON `contacts_deals`.`contact_id` = `contacts`.`id` 
        WHERE (`contacts_deals`.`deal_id` IS NULL 
          OR `contacts_deals`.`deal_id` != #{deal.id})
    SQL

    find_by_sql(sql)
  end

  #
  # Carrierwave
  #
  mount_uploader :avatar, AvatarUploader
  def thumb(options = {}); self.avatar end

  # The parameters for building the JS template for associated users
  def self.users_build_parameters # :nodoc:
    { :status => User::Status::Prospect }
  end

  ##
  # Setting company name will attempt to find a Company or create a new one
  #
  def company_name=(value)
    if value.present?
      if existing_company = Company.find_by_name(value)
        self.company = existing_company
      else
        self.build_company(:name => value)
      end
    else
      self.company = nil
    end
  end
  delegate :name, :to => :company, :prefix => true, :allow_nil => true

  ##
  # Helper to concatenate a Contact's full name
  #
  def name
    [first_name, last_name].join(' ').to_s.strip
  end

  def merge_and_destroy!(other_contact)
    other_contact.users.clear_primary!

    self.users                               |= other_contact.users
    self.website_attributes                  |= other_contact.website_attributes
    self.address_attributes                  |= other_contact.address_attributes
    self.phone_number_attributes             |= other_contact.phone_number_attributes
    self.instant_messaging_handle_attributes |= other_contact.instant_messaging_handle_attributes

    other_contact.destroy
  end

  def valid?(context = nil)
    #
    # NOTE #valid? manages duplicate users and is a destructive process!
    # TODO move the logic that deletes/manages duplicate email'd users out of 
    #      #valid?, which probably should not be destructive
    #
    # When checking for validity, we're also checking to see if Users are being added
    # which have emails that already exist in the database.  If one is found, one of
    # two things will happen, depending on whether or not that User already has a
    # Contact record.  
    #
    # A.) If it does, the validation will return false immediately and add an error 
    #     suggesting a Contact merge.
    #
    # B.) If it does not, no error will be added, but the offending "user" association
    #     will be deleted and the Contact will be related to the pre-existing User with 
    #     that email.
    #
    # If more than one user associations are passed with the same email, it will be treated 
    # as a normal uniqueness error, until all emails passed are unique. At which time we
    # go back to the A/B scenario above.
    #
    super || begin
      unless errors.delete(:"users.email").blank?
        users.dup.each_with_index do |user, i|
          user.errors[:email].each do |error|
            if error.taken? && users.select {|u| u.email == user.email }.length == 1
              existing_user = User.find_by_email(user.email)

              if contact = existing_user.contact
                args = if new_record?
                  [contact, 'new', {:contact => self.attributes}]
                else
                  [contact, self]
                end

                errors.add(:users, :merge_required, {
                  :email => user.email, 
                  :merge_path => new_contact_merge_path(*args)
                })

                return false
              else
                self.users.delete(user)
                self.users << existing_user
              end
            else
              if error.label
                errors.add(:users, error.label.to_sym, :email => user.email)
              else
                errors.add(:users, nil, :message => error, :email => user.email)
              end
            end
          end
        end

        errors[:users].uniq!
        errors[:users].empty?
      end
    end
  end

  def to_liquid
    Drop.new(self)
  end

  protected

    def _assign_initialization_defaults
      self.status ||= Status::Contact
    end

    def ensure_user_references
      users.each {|u| u.contact = self }
    end

    # override has_destroy_flag? to force destroy on persisted associations as well
    def has_destroy_flag?(hash)
      reject_record_attribute?(hash) || super 
    end

    #
    # #TODO figure out exactly how to handle rejection of Users
    #
    def reject_record_attribute?(attributes)
      attributes.keys.member?('value') && attributes['value'].blank? ||
        attributes.keys.member?('email') && attributes['email'].blank?
    end

    def ensure_no_associated_deals
      unless self.associated_deals.empty?
        errors.add(:associated_deals, :delete_restricted)
        false
      end
    end

  class Drop < ::E9::Liquid::Drops::Base
    source_methods :first_name, :last_name, :name, :email, :title, :company_name
  end

  module Status
    VALUES      = %w(contact sales_person affiliate)
    Contact     = VALUES[0]
    SalesPerson = VALUES[1]
    Affiliate   = VALUES[2]
  end
end
