# An "Email" that isn't intended to be sent, but rather as a prototype
# for other Emails to be generated from.
#
class EmailTemplate < Email
  # TODO the email class hierarchy needs a major refactoring, it's backwards and convoluted
  before_save :generate_html_body_from_text_body
end
