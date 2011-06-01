# An "Email" that isn't intended to be sent, but rather as a prototype
# for other Emails to be generated from.
#
class EmailTemplate < Email
  # TODO the email class hierarchy needs a major refactoring, it's backwards and convoluted
  before_save :generate_html_body_from_text_body

  validates :from_email, :email => { :allow_blank => true }

  def as_json(options = {})
    {}.tap do |hash|
      hash[:to]        = recipient.email
      hash[:reply_to]  = reply_email
      hash[:from]      = from_email
      hash[:subject]   = render(:subject)
      hash[:html_body] = render(:html_body)
      hash[:text_body] = render(:text_body)
    end
  end
end
