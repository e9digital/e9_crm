class Contact < ActiveRecord::Base
  include E9Tags::Model
  include E9Rails::ActiveRecord::AttributeSearchable

  ##
  # Associations
  #
  belongs_to :company
  has_many :users, :dependent => :nullify do
    def primary
      all.detect(&:primary?)
    end

    def reset_primary!
      each_with_index do |user, i|
        user.options.primary = i == 0
        user.save(:validate => false) if user.options_changed?
      end
    end
  end

  accepts_nested_attributes_for :users, :allow_destroy => true

  has_many :record_attributes, :as => :record

  RECORD_ATTRIBUTES = %w[users phone_number_attributes instant_messaging_handle_attributes website_attributes address_attributes]
  RECORD_ATTRIBUTES.select {|r| r =~ /attributes$/ }.each do |association_name|
    has_many association_name.to_sym, :class_name => association_name.classify, :as => :record
    accepts_nested_attributes_for association_name.to_sym, :allow_destroy => true, :reject_if => :reject_record_attribute?
  end

  ##
  # Validations
  #

  validates :first_name,  :length   => { :maximum => 25 }

  #validates_associated :users

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
      any_attrs_like_scope_conditions(:first_name, :last_name, :title, query).or(
        RecordAttribute.attr_like_scope_condition(:value, query)
      )
    )
  }

  def company_name=(value)
    unless value.blank?
      if existing_company = Company.find_by_name(value)
        self.company = existing_company
      else
        self.build_company(:name => value)
      end
    end
  end
  delegate :name, :to => :company, :prefix => true, :allow_nil => true

  def name
    [first_name, last_name].join(' ')
  end

  def self.users_build_parameters
    { :status => User::Status::PROSPECT }
  end

  protected

    # override has_destroy_flag? to force destroy on persisted associations as well
    def has_destroy_flag?(hash)
      reject_record_attribute?(hash) || super 
    end

    def reject_record_attribute?(attributes)
      attributes.keys.member?(:value) && attributes[:value].blank?
    end

end
