module E9Crm::ContactMergesHelper
  def contact_a(field_name)
    @_contact_a_vals ||= {}
    @_contact_a_vals[field_name] ||= merge_contact_val(@contact_a, field_name)
  end

  def contact_b(field_name)
    @_contact_b_vals ||= {}
    @_contact_b_vals[field_name] ||= merge_contact_val(@contact_b, field_name)
  end

  def merge_contact_val(obj, field_name)
    # return '' here rather than nil so inputs will have a value, otherwise checked
    # with no value ends up being interpreted as "on"
    obj.send(field_name) || ''
  end
end
