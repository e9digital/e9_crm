class Contact < ActiveRecord::Base
  include E9Tags::Model
  include E9Rails::ActiveRecord::AttributeSearchable

  # necessary so contact knows its merge path
  include Rails.application.routes.url_helpers

  before_validation :ensure_user_references
  before_save :reset_primary_user

  ##
  # Associations
  #
  belongs_to :company
  has_many :users, :dependent => :nullify do
    def primary
      detect(&:primary?)
    end

    def reset_primary(options = {})
      return if empty?
      options.symbolize_keys!
      options.slice!(:id, :index, :save)

      should_save = options.delete(:save)

      if options.empty?
        if p = primary
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

    def reset_primary!(options = {})
      reset_primary options.merge(:save => true)
    end

    def clear_primary(options = {})
      reset_primary options.merge(:index => -1)
    end

    def clear_primary!
      clear_primary :save => true 
    end
  end
  accepts_nested_attributes_for :users, :allow_destroy => true

  has_many :record_attributes, :as => :record
  RECORD_ATTRIBUTES = %w[users phone_number_attributes instant_messaging_handle_attributes website_attributes address_attributes]
  # NOTE Mind the hack here, "users" are "attributes" but not added in this loop.  This was so the RECORD_ATTRIBUTES constant
  #      would include :users (for building the templates.js).
  RECORD_ATTRIBUTES.select {|r| r =~ /attributes$/ }.each do |association_name|
    has_many association_name.to_sym, :class_name => association_name.classify, :as => :record
    accepts_nested_attributes_for association_name.to_sym, :allow_destroy => true, :reject_if => :reject_record_attribute?
  end

  ##
  # Validations
  #

  validates :first_name, :presence => true,
                         :length   => { :maximum => 25 }

  ##
  # Scopes
  #

  scope :by_title, lambda {|val| where(:title => val) }
  scope :by_company, lambda {|val| where(:company_id => val) }

  scope :tagged, lambda {|tags| 
    unless tags.blank?
      tagged_with(tags, :show_hidden => true, :any => true) 
    else
      where("1=0")
    end
  }

  scope :search, lambda {|query|
    # NOTE to_sql on this query doesn't read what it actually executes, including the join...
    includes(:record_attributes).where(
      any_attrs_like_scope_conditions(:first_name, :last_name, :title, query).or(
        RecordAttribute.attr_like_scope_condition(:value, query)
      )
    )
  }

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

  def name
    [first_name, last_name].join(' ')
  end

  def self.users_build_parameters
    { :status => User::Status::PROSPECT }
  end

  def merge_and_destroy!(other_contact)
    other_contact.users.clear_primary!

    self.users |= other_contact.users
    self.website_attributes |= other_contact.website_attributes
    self.address_attributes |= other_contact.address_attributes
    self.phone_number_attributes |= other_contact.phone_number_attributes
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
      if errors[:"users.email"].present?
        errors.delete(:"users.email")

        users.dup.each_with_index do |user, i|
          user.errors[:email].each do |error|
            if error.taken? && users.select {|u| u.email == user.email }.length == 1
              existing_user = User.find_by_email(user.email)

              if contact = existing_user.contact
                errors.add(:users, :merge_required, :email => user.email, :merge_path => new_contact_merge_path(self, contact))
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

  protected

    def ensure_user_references
      users.each {|u| u.contact = self }
    end

    def reset_primary_user
      users.reset_primary
    end

    # override has_destroy_flag? to force destroy on persisted associations as well
    def has_destroy_flag?(hash)
      reject_record_attribute?(hash) || super 
    end

    def reject_record_attribute?(attributes)
      attributes.keys.member?(:value) && attributes[:value].blank?
    end

end
