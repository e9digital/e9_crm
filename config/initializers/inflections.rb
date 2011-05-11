ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^(\w*cookie)s$/i, '\1'
end
