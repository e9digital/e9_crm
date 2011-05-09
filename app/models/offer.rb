# A +Renderable+ which "offers" the user something.  Responses to these
# offers are tracked as +Leads+
#
class Offer < Renderable
  has_many :leads

end
