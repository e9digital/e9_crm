class Contact < ActiveRecord::Base
  include E9Tags::Model

  scope :tagged, lambda {|tag| tagged_with(tag, :show_hidden => true) }
end
