# A ContactEmail is a one time mail generated from an EmailTemplate, sent not to a 
# list, but to a set of contact_ids.
#
class ContactEmail < Email
  include ScheduledEmail
  before_save :generate_html_body_from_text_body

  validates :contact_ids, :presence => true
  validates :user_ids, :presence => { :unless => lambda {|r| r.contact_ids.blank? } }

  after_create :send_to_user_ids

  class << self
    def new_from_template(template, attrs = {})
      new({
        :name       => "#{template.name} - #{DateTime.now.to_i}",
        :subject    => template.subject,
        :from_email => template.from_email,
        :html_body  => template.html_body,
        :text_body  => template.text_body
      }.merge(attrs))
    end
  end

  # contact_ids only gets set if it's an array or a properly formatted string
  def contact_ids=(val)
    @contact_ids = case val
                   when /^\[?((\d+,?\s?)+)\]?$/
                     $1.split(',')
                   when Array
                     val
                   else
                     []
                   end

    # clear user_ids cache
    @user_ids = nil
  end

  def contact_ids
    (@contact_ids ||= []).map(&:to_i)
  end


  def user_ids 
    @user_ids ||= if @contact_ids.present?
      user_scope  = (User.primary.joins(:contact) & Contact.where(:id => @contact_ids))
      user_id_sql = user_scope.select('users.id').to_sql
      User.connection.send(:select_values, user_id_sql, 'User ID Load')
    else
      []
    end
  end

  protected

  def send_to_user_ids
    Rails.logger.info("ContactEmail##{id} sending to user ids #{user_ids}")
    send!(user_ids)
  end
end
