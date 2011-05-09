# A +Renderable+ which "offers" the user something.  Responses to these
# offers are tracked as +Leads+
#
class Offer < Renderable
  has_many :leads

  def to_s
    name
  end

  validates :template, :presence => true

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]       = self.id,
      hash[:name]     = self.name,
      hash[:template] = self.template,
      hash[:answers]  = self.answers,
      hash[:errors]   = self.errors
    end
  end

  def answers
    []
  end

  protected

  def reject_answer?(attributes)
    !attributes.keys.member?('value') || attributes['value'].blank?
  end
end
