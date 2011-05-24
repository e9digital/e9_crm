module E9Crm::LeadsHelper
  def custom_offer_form_fields(offer, form)
    @offer.parsed_custom_form_data.each do |field|
      field.symbolize_keys!

      case field[:type]
      when 'select'    then render_custom_offer_select(field, form)
      when 'checkbox'  then render_custom_offer_checkbox(field, form)
      when 'radio'     then render_custom_offer_radio(field, form)
      when 'textfield' then render_custom_offer_textfield(field, form)
      when 'textarea'  then render_custom_offer_textarea(field, form)
      end
    end
  end

  def render_custom_offer_select(field, form)
    label_html  = field[:required] ? form.label(field[:name], nil, :class => :req) : form.label(field[:name])
    select_html = form.select field[:name], options_for_select(field[:options])
    safe_concat <<-HTML
      <div class="field">
        #{label_html}
        #{select_html}
      </div>
    HTML
  end

  def render_custom_offer_checkbox(field, form)
    label_html    = field[:required] ? form.label(field[:name], nil, :class => :req) : form.label(field[:name])
    safe_concat <<-HTML
      <div class="field checkbox">
        #{label_html}
      </div>
    HTML
  end

  def render_custom_offer_textfield(field, form)
    label_html = field[:required] ? form.label(field[:name], nil, :class => :req) : form.label(field[:name])

    safe_concat <<-HTML
      <div class="field">
        #{label_html}
      </div>
    HTML
  end

  def render_custom_offer_textarea(field, form)
    label_html = field[:required] ? form.label(field[:name], nil, :class => :req) : form.label(field[:name])

    safe_concat <<-HTML
      <div class="field">
        #{label_html}
      </div>
    HTML
  end

  def render_custom_offer_radio(field, form)
    safe_concat <<-HTML
      <div class="field radio">

      </div>
    HTML
  end
end
