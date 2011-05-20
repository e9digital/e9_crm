jQuery(function($) {

  $('.dated-costs > .actions a').bind('ajax:success', function(e, data, status, xhr) {
    $(data).insertBefore($(this).closest('.actions'));
  });

  /*
   * A function might exist for this already, but basically this stores the query variables
   * in a hash when the page loads for later re-use/modification.
   */
  function query_to_hash(qs) {
    if (!qs) qs = document.location.search;

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
  }

  $.query = query_to_hash();

  $.fn.bindSelectChange = function(callback) {
    this.bind($.browser.msie ? 'propertychange' : 'change', callback);
  }

  $("#campaign_code_field input").keyup(function() {
    $.event.trigger('campaign_code_change', [$(this).val()]);
  });

  $("#campaign_code_hint").bind("campaign_code_change", function(e, code) {
    $(this).html(function(i, v) {
      return v.replace(/=(.*)$/, '='+code);
    });
  });

  $('.ordered-column a').live('click', function(e) {
    e.preventDefault();

    var $this = $(this),
         href = $this.attr('href'),
         qs   = href.match(/\?.*$/)[0];

    var qh = qs && query_to_hash(qs) || {};

    $.extend($.query, {
      order : qh.order,
      sort  : qh.sort
    });

    submit_with_query();
  });

  $("#campaign_search_form").each(function(i, el) {
    var 
    $form = $(el),
    $st   = $(el).find('select[name=type]'),
    $sg   = $(el).find('select[name=group]'),
    $sa   = $(el).find('select[name=active]'),
    $sf   = $(el).find('select[name=from]'),
    $su   = $(el).find('select[name=until]')
    ;

    $st.val($.query.type);
    $sg.val($.query.group);
    $sa.val($.query.active);
    $sf.val($.query.from);
    $su.val($.query.until);

    $('select', $form).bindSelectChange(function() {
      var opts = {}, v;
      if (v = $st.val()) {
        opts['type'] = v;
      } else {
        delete $.query['type'];
      }
      if (v = $sg.val()) { 
        opts['group']  = v;
      } else {
        delete $.query['group'];
      }
      if (v = $sa.val()) {
        opts['active'] = v;
      } else {
        delete $.query['active'];
      }
      if (v = $sf.val()) {
        opts['from'] = v;
      } else {
        delete $.query['from'];
      }
      if (v = $su.val()) {
        opts['until'] = v;
      } else {
        delete $.query['until'];
      }
      $.extend($.query, opts);
      submit_with_query();
    });
  });

  $("#new_campaign_form").each(function(i, el) {
    var $form = $(el);

    $('select', $form).bindSelectChange(function() {
      var $this = $(this);

      $form.attr("action", function(i, val) {
        return val.replace(/\/\w*\/new$/, '/'+$this.val()+'/new');
      });
    });
  });

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
   * The status of "primary" for a User login is stored on the individual records, but must be exlcusive in
   * the scope of the Contact (only one User may be primary).
   *
   * NOTE This function is called initially, then after adding new nested associations to the page.
   */
  var exclusifyEmailRadios;
  (exclusifyEmailRadios = function() {
    $('.nested-association input[type=radio][name$="[primary]"]', $(selector_prefix)).exclusiveCheck();
  })();

  /*
   * Adds a new nested assocation.  Depends on the nested association
   * js templates being loaded.
   */
  $('a.add-nested-association').click(function(e) {
    e.preventDefault();

    var $this = $(this), template;

    // get the template for this attribute type
    try { 
      template = E9CRM.js_templates[this.getAttribute('data-association')];
    } catch(e) { return }

    // sub in the current index and increment it
    template = template.replace(
      new RegExp(E9CRM.js_templates.start_child_index, 'g'), 
      ++E9CRM.js_templates.current_child_index
    );

    // and insert the new template before this link
    $(template).insertBefore($this);

    exclusifyEmailRadios();
  });

  /*
   * Effectively destroys an added nested association, removing the container
   * the association is not persisted, or hiding it and setting the _destroy
   * parameter for the association if it is.
   */
  $('a.destroy-nested-association').live('click', function(e) {
    e.preventDefault();

    // grab the parent nested-association and attempt to get its hidden
    // 'destroy' input if it exists.
    var $parent = $(this).closest('.nested-association').hide(),
        $destro = $parent.find('input[id$=__destroy]');

    // If a in input ending in __destroy was found it means that this is a
    // persisted record.  Set that input's value to '1' so it will be destroyed
    // on record commit.
    if ($destro.length) { $destro.val('1'); }

    // otherwise this record was created locally and has not been saved, so
    // simply remove it.
    else { $parent.remove(); }
  });

  var submit_with_query = function(data) {
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

    submit_with_query();
  });

  $('form#contact_search_form', $(selector_prefix)).live('submit', function(e) {
    e.preventDefault();

    $.extend($.query, {
      'search': $(this).find('input[name=search]').val()
    });

    submit_with_query();
  });

  $('input#contact_search_clear', $(selector_prefix)).live('click', function(e) {

    $(selector_prefix)
      .find('form#contact_search_form input[name=search]', $selector).val('').end()
      .find('.tag-table input[name="tagged[]"]', $selector).attr('checked', false)
    ;

    $.query = {};

    submit_with_query();
  });

  //$('#menu_option_key_select_form select').bindSelectChange(function(e) {
    //$(this).submit();
  //});
});
