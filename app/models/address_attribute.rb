# Attribute for address info
#
class AddressAttribute < RecordAttribute
  def to_html
    to_s.gsub(/\n/, '<br />').html_safe
  end
end
