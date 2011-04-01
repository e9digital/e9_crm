class ContactEmail < Email
  include ScheduledEmail
  before_save :generate_html_body_from_text_body

  # NOTE perhaps contact_email should validate contact ids?
  #      then again, then you'd need to ensure the contacts
  #      had primary email addresses
  validates :user_ids, :presence => true

  after_create :send_to_user_ids

  class << self
    def new_from_template(template, attrs = {})
      new({
        :name => "#{template.name} - #{DateTime.now.to_i}",
        :subject => template.subject,
        :html_body => template.html_body,
        :text_body => template.text_body
      }.merge(attrs))
    end
  end

  attr_reader :user_ids

  # user_ids only gets set if it's an array or a properly formatted string
  def user_ids=(val)
    @user_ids = case val
                when /^\[?((\d+,?\s?)+)\]?$/
                  $1.split(',')
                when Array
                  val
                else
                  []
                end

    @user_ids.map!(&:to_i)
  end


  protected

  def send_to_user_ids
    Rails.logger.info("SENDING : #{user_ids}")
    send!(user_ids)
  end
end
