;jQuery(function($) {

  /*
   * add offer class handler to quick_edit.
   */
  $.quick_edit = $.quick_edit || {};
  $.quick_edit.class_handlers = $.extend({
    'offer' : function(el) {
      var path   = el.attr('data-renderable-path'), 
          npath  = el.attr('data-update-node-path'),
          epath  = path + '/edit';

      //return '<a class="qe-qelink" href="'+ epath +'">Edit</a>' +
      return '<a class="qe-ulink"  href="'+ npath +'">Switch</a>' +
             '<a class="qe-elink"  href="'+ epath +'">Admin</a>';
    }
  }, $.quick_edit.class_handlers);

  /* 
   *
   */
  $('.dated-costs > .actions a').bind('ajax:success', function(e, data, status, xhr) {
    $(data).insertBefore($(this).closest('.actions'));
  });

  $("#campaign_code_field input").keyup(function() {
    $.event.trigger('campaign_code_change', [$(this).val()]);
  });

  $("#campaign_code_hint").bind("campaign_code_change", function(e, code) {
    $(this).html(function(i, v) {
      return v.replace(/=(.*)$/, '='+code);
    });
  });

  /*
   * change the value of the new menu option type link when the scope select
   * changes, e.g. when viewing "Email" menu options, clicking "Add Menu Option"
   * defaults to creating a new email menu option.
   */
  $('body.admin a.new-menu-option').bind('scope-select:change:key', function(e, v) {
    $(this).attr('href', function(i, val) {
      return val.replace(/\[key\]=([^&]*)/, '[key]='+encodeURIComponent(v));
    });
  });


  $("body.admin form#new_campaign_form, body.admin form#new_offer_form").each(function(i, el) {
    var $form = $(el);

    $('select', $form).bindSelectChange(function() {
      var $this = $(this);
      $form.attr("action", function(i, val) {
        return val.replace(/\/\w*\/new$/, '/'+$this.val()+'/new');
      });
    });

    $form.submit(function(e) {
      e.preventDefault();
      window.location = $form.attr('action');
    });
  });

  var selector_prefix = 'body.controller-e9-crm-contacts', 
      $selector       = $(selector_prefix);

  /*
   * The status of "primary" for a User login is stored on the individual records, but must be exlcusive in
   * the scope of the Contact (only one User may be primary).
   *
   * NOTE This function is called initially, then after adding new nested associations to the page.
   */
  var exclusifyEmailRadios;
  (exclusifyEmailRadios = function() {
    var $radios = $('.nested-association input[type=radio][name$="[primary]"]', $(selector_prefix));

    if (!$radios.is(':checked')) $radios.first().attr('checked', true);
    
    $radios.exclusiveCheck();
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


  $('#contact_email_form', $selector).live('submit', function(e) {
    var $f = $(this);

    if ($f.attr('data-count') == '0') {
      alert($f.attr('data-empty'));
      $f.undisable();
      return false;
    }
  });

  //$('#contact_newsletter_form', $selector).live('submit', function(e) {
    //e.preventDefault();

    //var $f = $(this);

    /*
     * if no options, simply return (this shouldn't happen)
     */
    //if (!$('select', this).children().length) {
      //$f.undisable();
      //return false;
    //}

    /*
     * warn if no selected contacts
     */
    //if ($f.attr('data-count') == '0') {
      //alert($f.attr('data-empty'));
      //$f.undisable();
      //return false;
    //}

    /*
     * run confirm
     */
    //if (!confirm($f.attr('data-confirm'))) {
      //$f.undisable();
      //return false;
    //}

    /*
     * mod the form action to send to the correct email
     */
    //$f.attr('action', function(i, val) {
      //return val.replace(/__ID__/, $('#eid', $f).val());
    //});

    /*
     * we're going to remove the selected email from the options on completion, or
     * the whole form if there are no more emails to send.
     */
    //var $sel       = $('option:selected', $f);
        //$to_remove = $sel.siblings().length ? $sel : $f;

    //$f.bind('ajax:complete', function() { $to_remove.remove(); });


    //$f.callRemote();
  //});

  $('.tag-holder', $selector).change(function(e) {
    $.extend($.query, {
      'tagged[]': $.makeArray($(this).find('input[name="tagged[]"]').map(function(i, el) { return $(el).attr('checked') ? $(el).val() : null }))
    });

    $.submit_with_query();
  });

  $('form#contact_search_form', $(selector_prefix)).live('submit', function(e) {
    e.preventDefault();

    $.extend($.query, {
      'search': $(this).find('input[name=search]').val()
    });

    $.submit_with_query();
  });

  $('input#contact_search_clear', $(selector_prefix)).live('click', function(e) {

    $(selector_prefix)
      .find('form#contact_search_form input[name=search]', $selector).val('').end()
      .find('.tag-table input[name="tagged[]"]', $selector).attr('checked', false)
    ;

    $.query = {};

    $.submit_with_query();
  });

});
