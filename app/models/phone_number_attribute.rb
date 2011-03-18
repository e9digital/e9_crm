class PhoneNumberAttribute < RecordAttribute
  self.options_parameters = [:type]

  def to_s
    retv = super
    retv = "%s (%s)" % [retv, options.type] if options.type
    retv
  end
end
