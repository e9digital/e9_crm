jQuery(function($) {
  var selector_prefix = 'body.controller-e9-crm-contacts', 
      $selector       = $(selector_prefix);

  $.fn.exclusiveCheck = function() {
    var selector = $(this);
    return this.each(function(i) {
      $(this).click(function(e) {
        var clicked = this;
        if (this.checked) {
          selector.each(function() {
            if (this != clicked) this.checked = false;
          });
        }
      });
    });
  }

  /*
   * A function might exist for this already, but basically this stores the query variables
   * in a hash when the page loads for later re-use/modification.
   */
  $.query = (function() {
    var qs = document.location.search;

    if (!qs.length) return {};
      
    var params = {},
        regex  = /[?&]?([^=]+)=([^&]*)/g,
        tokens, key, val;

    qs = qs.split('+').join(' ');

    while (tokens = regex.exec(qs)) {
      key = decodeURIComponent(tokens[1]);
      val = decodeURIComponent(tokens[2]);

      if(/\[\]$/.test(key)) {
        if (!params[key]) params[key] = [];
        params[key].push(val);
      } else {
        params[key] = val;
      }
    }

    return params;
  })();

  /*
   * The status of "primary" for a User login is stored on the individual records, but must be exlcusive in
   * the scope of the Contact (only one User may be primary).
   *
   * NOTE This function is called initially, then after adding new nested associations to the page.
   */
  var exclusifyEmailRadios;
  (exclusifyEmailRadios = function() {
    $('.nested-association input[type=radio][name$="[primary]"]', $(selector_prefix)).exclusiveCheck();
  })();

  /**
   * Adds a new nested assocation.  Depends on the nested association
   * js templates being loaded.
   */
  $('a.add-nested-association').click(function(e) {
    e.preventDefault();

    var $this   = $(this), 
        $parent = $this.closest('.nested-associations'),
        template,
        index;

    try { 
      template = E9CRM.js_templates[this.getAttribute('data-association')];
    } catch(e) { return }

    template = template.replace(
      new RegExp(E9CRM.js_templates.start_child_index, 'g'), 
      ++E9CRM.js_templates.current_child_index
    );

    $(template).appendTo($parent);

    exclusifyEmailRadios();
  });

  /**
   * Effectively destroys an added nested association, removing the container
   * the association is not persisted, or hiding it and setting the _destroy
   * parameter for the association if it is.
   */
  $('a.destroy-nested-association').live('click', function(e) {
    e.preventDefault();

    var $parent = $(this).closest('.nested-association').hide(),
        $destro = $parent.find('input[id$=__destroy]');

    if ($destro.length) {
      $destro.val('1');
    } else {
      $parent.remove();
    }
  });

  var filter_contacts = function(data) {
    $.ajax({
      dataType: 'script',
      url: window.location.pathname,
      data: data || $.param($.query)
    });
  }

  $('#contact_email_form', $selector).live('submit', function(e) {
    var $f = $(this);

    if ($f.attr('data-count') == '0') {
      alert($f.attr('data-empty'));
      $f.undisable();
      return false;
    }
  });

  $.fn.undisable = function() {
    $('input[type=submit]', this).removeAttr('disabled').removeClass('ui-state-hover').blur();
  }

  $('#contact_newsletter_form', $selector).live('submit', function(e) {
    e.preventDefault();

    var $f = $(this);

    if (!$('select', this).children().length) {
      $f.undisable();
      return false;
    }

    if ($f.attr('data-count') == '0') {
      alert($f.attr('data-empty'));
      $f.undisable();
      return false;
    }

    if (!confirm($f.attr('data-confirm'))) {
      $f.undisable();
      return false;
    }

    $f.attr('action', function(i, val) {
      return val.replace(/__ID__/, $('#eid', $f).val());
    });

    $f.callRemote();
  });

  $('.tag-table', $selector).change(function(e) {
    $.extend($.query, {
      'tagged[]': $.makeArray($(this).find('input[name="tagged[]"]').map(function(i, el) { return $(el).attr('checked') ? $(el).val() : null }))
    });

    filter_contacts();
  });

  $('form#contact_search_form', $(selector_prefix)).live('submit', function(e) {
    e.preventDefault();

    $.extend($.query, {
      'search': $(this).find('input[name=search]').val()
    });

    filter_contacts();
  });

  $('input#contact_search_clear', $(selector_prefix)).live('click', function(e) {

    $(selector_prefix)
      .find('form#contact_search_form input[name=search]', $selector).val('').end()
      .find('.tag-table input[name="tagged[]"]', $selector).attr('checked', false)
    ;

    $.query = {};

    filter_contacts();
  });

  //$('#menu_option_key_select_form select').change(function(e) {
    //$(this).submit();
  //});
});
