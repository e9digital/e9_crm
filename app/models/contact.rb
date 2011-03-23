class Contact < ActiveRecord::Base
  include E9Tags::Model
  include E9Rails::ActiveRecord::AttributeSearchable

  ##
  # Callbacks
  #

  #
  # A contact should always have at least one "User", which at
  # a minimum would be an unregistered User prospect.
  #
  # A contact should always designate one User as "primary"
  # if it has Users.
  #
  after_save :find_or_create_associated_user_and_update_primary_user

  ##
  # Associations
  #

  #
  # Destroying should nullify User's Contact relation, but leave
  # the user intact.
  #
  # Oppositely, destroying a User should nullify the Contact's
  # primary_user relation but leave the Contact intact.
  #
  has_many :users, :dependent => :nullify

  belongs_to :primary_user, :class_name => 'User'
  belongs_to :company

  # record attribute assocations
  has_many :record_attributes, :as => :record

  RECORD_ATTRIBUTES = %w[phone_number_attributes instant_messaging_handle_attributes website_attributes address_attributes]
  RECORD_ATTRIBUTES.each do |association_name|
    has_many association_name, :class_name => association_name.classify, :as => :record
    accepts_nested_attributes_for association_name, :allow_destroy => true, :reject_if => :reject_record_attribute?
  end

  ##
  # Validations
  #

  validates :email, 
            :presence     => true,
            :uniqueness   => { :case_sensitive => false },
            :email        => { :allow_blank => true },
            :length       => { :maximum => 500 }
  validates :first_name,
            :length       => { :maximum => 25 }

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
    select('distinct contacts.*').
    joins(:record_attributes).where(
      any_attrs_like_scope_conditions( :first_name, :last_name, :title, query).or(
        RecordAttribute.attr_like_scope_condition(:value, query)
      )
    )
  }

  delegate :primary_email, :to => :primary_user, :allow_nil => true

  delegate :name, :to => :company, :prefix => true, :allow_nil => true

  def company_name=(value)
    unless value.blank?
      if existing_company = Company.find_by_name(value)
        self.company = existing_company
      else
        self.build_company(:name => value)
      end
    end
  end

  def name
    [first_name, last_name].join(' ')
  end

  # Reset the primary user to the first user, ignoring
  # the User passed as :reject option
  #
  def reset_primary_user!(options = {})
    ids = user_ids.dup

    if options[:reject].is_a?(User)
      ids.reject! {|i| i == options[:reject].id }
    end

    if primary_user_id != ids.first
      update_attribute(:primary_user_id, ids.first) 
    end
  end

  protected

    # override has_destroy_flag? to force destroy on persisted associations as well
    def has_destroy_flag?(hash)
      reject_record_attribute?(hash) || super 
    end

    def reject_record_attribute?(attributes)
      attributes[:value].blank?
    end

    def associated_user_parameters
      {
        :email => self.email,
        :first_name => self.first_name,
        :status => User::Status::PROSPECT
      }
    end

    def find_or_create_associated_user_and_update_primary_user
      if users.empty?
        if existing_user = User.find_by_email(self.email)
          users << existing_user 
        else
          users.create(associated_user_parameters)
        end
      end

      if primary_user.blank? || !user_ids.member?(primary_user_id)
        self.reset_primary_user!
      end
    end

end
