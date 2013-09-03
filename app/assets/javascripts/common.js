$(function(){

  // Set Russian cultute for Globalize plugin as default
  if (window.Globalize) {
    Globalize.culture('ru');
  }

  // Toggle checked attribute for hidden checkbox by clicking on corresponding label
  $(document.body).on('click', 'label.checkbox', function(e){
    e.preventDefault();
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for')),
        confirm_msg = $t.data('confirm');
    if ($t.hasClass('disabled')) { return; }
    if (confirm_msg && !confirm(confirm_msg)) { return; }
    $t.toggleClass('active');
    $checkbox.attr('checked', $t.hasClass('active')).trigger('change');
  });
  $('label.checkbox').each(function() { // Set initial state for label.checkbox's
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for'));
    $t[$checkbox.is(':checked') ? 'addClass' : 'removeClass']('active');
    $t[$checkbox.is(':disabled') ? 'addClass' : 'removeClass']('disabled');
  });

  // $('.editable-select').editableSelect({
  //   bg_iframe: true,
  //   onSelect: function(list_item) {
  //     // alert('List item text: '+ list_item.text());
  //     // 'this' is a reference to the instance of EditableSelect
  //     // object, so you have full access to everything there
  //     // alert('Input value: '+ this.text.val());
  //   },
  //   case_sensitive: false, // If set to true, the user has to type in an exact
  //                       // match for the item to get highlighted
  //   items_then_scroll: 10 // If there are more than 10 items, display a scrollbar
  // });

  // user color
  $('#user_color').live('change', function(event){
    $('.color_sample').css('background-color', $(event.currentTarget).val());
  });
  $('.color_sample').css('background-color', $('#user_color').val());
  $('#user_color option').each(function() {
    var $t = $(this);
    $t.html('<span class="circular colored" style="background-color: ' + $t.val() + ';"></span> ' + $t.text());
    // $t.ikSelect('reset');
  });

  $('#tour_price input, #payments_in input, #payments_out input').click(function(e){
    e.currentTarget.select();
  });

  $('#user_color').keyup(function(event){
    $('.color_sample').css('background-color', $(event.currentTarget).val());
  });

  // popups
  function show_popup(e){
    $('#popup').height($('#content').height()).show();
    var classes = $(e.currentTarget).attr('class').split(' ');
    for (var i in classes) {
      if (/[a-z_]+_form$/.test(classes[i])) {
        $('.window#' + classes[i]).fadeIn();
        break;
      }
    }
  }

  $('a.show_popup').click(function(e){
    e.preventDefault();
    show_popup(e);
  });

  $('.window .close').click(function(e) {
    e.preventDefault();
    $('#popup').fadeOut(300);
    $('.window').hide();
  });

  //password reset form
  $('a.password_reset_form').click(function(e){
    e.preventDefault();
    $.ajax({
      url: $(e.currentTarget).attr('href'),
      success: function(resp){
        $('.window .content').empty().append(resp);
      },
      async: false
    });
    show_popup(e);
  });

  // view switcher
  $('#view_switcher').change(function(e) {
    location.search = 'list_type=' + $(this).val();
  });

  // trigger function exclusively after corresponding timeout
  window.exclusive_delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
    };
  })();

  // bind submitting form for links with data-submit attribute
  $('a[data-submit]').on('click', function(e) {
    e.preventDefault();
    var form_id = $(this).data('submit'),
        $form = $('#' + form_id);
    if ($(this).data('close')) {
      var $inp = $form.find('input[name="save_and_close"]');
      if ($inp.length) {
        $inp.val('1');
      } else {
        $form.append('<input type="hidden" name="save_and_close" value="1" />');
      }
    }
    if (form_id && $form.length) {
      $form[0].submit(); // sometimes after redirecting $form.submit() don't work, maibe it's bug in jquery 1.7.1
    }
  });

  // $('.error_message.input_wrapper').each(function() {
  //   var $t = $(this),
  //       errors = $t.attr('title'),
  //       $i = $t.find(':input');
  //   var tooltip_options = {
  //     template: '<div class="tooltip error_message"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',
  //     placement: 'top'
  //   };
  //   if (errors.length) {
  //     if ($i.data('errors-text') === false) {
  //       $t.tooltip(tooltip_options);
  //       return;
  //     }
  //     $t.css('width', $t.width());
  //     var $ell = $('<div class="errors ellipsis">' + errors + '</div>').appendTo($t);
  //     $ell.dotdotdot({ wrap: 'letter' });
  //     if ($ell.triggerHandler("isTruncated"))
  //       $t.tooltip(tooltip_options);
  //     else
  //       $t.attr('title', '');
  //   }
  // });

  $('.error_message.input_wrapper').tooltip({
    template: '<div class="tooltip error_message"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',
    placement: 'top'
  });

  $('.with_tooltip[title], label.required').tooltip();

  // Prevent default submit of fiter form
  $('form.filter').on('submit', function(e) { e.preventDefault(); });
  $('form.filter .go_search').on('click', function(e) {
    $('form.filter .search').trigger('keyup');
  });

  // Unset filters link
  $('form.filter .unset_filters, form.filter .filter_reset').on('click', function(e) {
    e.preventDefault();
    $('form.filter :input[data-param]').each(function() {
      var $t = $(this),
          defval = $t.data('default'),
          newval = defval !== undefined ? defval : '';
      if ($t.is('select')) {
        if (newval == '')
          newval = $t.find('option:first-child').val();
        $t.ikSelect('select', newval);
      } else if ($t.is(':checkbox')) {
        newval = (!newval || newval === 'false' || newval === '0') ? false : true;
        $t.attr('checked', newval);
        $('label[for="' + $t.attr('id') + '"]')[newval ? 'addClass' : 'removeClass']('active');
      } else {
        $t.val(newval);
      }
    });
    var data = {};
    if ($(this).hasClass('unset_filters')) {
      data['unset_filters'] = true;
    } else if ($(this).hasClass('filter_reset')) {
      data['filter_reset'] = true;
    }
    listRefresh(data);
  });

  bind_settings_dialog($('#settings-menu'));

  // Settings menu open button
  $('#settings').on('click', function(e) {
    e.preventDefault();
    $('#settings-menu')
      .dialog('option', 'position', { my: 'right top', at: 'right bottom', of: this })
      .dialog('open');
  });

  // // Settings menu buttons handlers
  $('#settings-menu').on('click', '[role="button"]', function(e) {
    e.stopPropagation();
    var $t = $(this),
        act = $t.attr('rel'),
        $menu = $t.closest('#settings-menu');
    if (act == 'save') {
      listRefresh();
      // $menu.dropdown('toggle');
      $menu.dialog('close');
    } else if (act == 'close') {
      $(':input[data-param]', $menu).each(function() {
        var $t = $(this),
            curval = $t.data('current-value');
        if (curval !== undefined) {
          $t.val(curval).removeData('current-value');
        }
      });
      // $menu.dropdown('toggle');
      $menu.dialog('close');
    }
  });

  // bind handle for on success after remote record deletion
  $('body').on('ajax:success', 'a.delete[data-remote]', function(e) {
    // if it'is reservations table, just remove appropriate row
    var $table = $(this).closest('.reservations');
    if ($(this).closest('table.reservations').length) {
      $(this).closest('tr').remove();
    } else {
      listRefresh();
    }
  });

  // initialize autocompletes
  // setAutocomplete();

  // customize all selects
  customizeSelect();

  // set default date and datetime pickers
  setDatepicker();
  setDatetimepicker();
  // change years for date_of_birth pickers
  $('.date_of_birth.hasDatepicker').datepicker('option', 'yearRange', 'c-100:c+0');

  // define screen resolution into browser cookie
  defineScreenResolution();

  // Refine bottom padding for content
  set_content_bottom_padding();

});

function setAutocomplete(selector, is_container, options) {
  var defsel = '.autocomplete',
      sel = selector || defsel,
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find(defsel);

  var defaults = {
    delay: 100,
    minLength: 0
    // open: function(event, ui) {
    //   var self = this,
    //       $widget = $(this).autocomplete('widget');
    //   $widget.find('.ui-menu-item a').filter(function() {
    //     return $(this).text() == self.value;
    //   }).addClass('ui-state-focus');
    // }
  };

  var is_reset = !!options;

  var _createAutocomplete = function($t, options) {
    var _opts = $.extend({}, defaults, $t.data('ac'), options);

    $t.autocomplete(_opts);

    if ($t.data('open_on_focus') !== false) {
      $t.on('focus', function(e) {
        $(this).autocomplete('search', this.value);
      });
    }
    // if hidden element with id appropriate id exists, use it for save selected id
    var $h = $('#' + $t.attr('id') + '_id');
    if ($h.length) {
      $t.on('autocompleteselect', function(event, ui) {
        $('#' + $(this).attr('id') + '_id').val(ui.item.id);
      }).on('blur', function() {
        if (!$(this).val().length) {
          $('#' + $(this).attr('id') + '_id').val('');
        }
      });
    }

    // TODO: temporary solution for adjust width and right padding
    if (parseInt($t.css('padding-right')) < 25) {
      $t.css({
        width: $t.width() - 25,
        paddingRight: 25
      });
    }

    // Adjust suggestion list width
    var $ul = $t.data('uiAutocomplete')['widget']();
    $ul.css('max-width', $t.outerWidth() - 2);
  };

  $sel.each(function() {
    var $t = $(this),
        current_ac = $t.data('uiAutocomplete');
    // Check already initialized autocomplete is setted already
    if (!current_ac) {
      _createAutocomplete($t, options);
    } else if (is_reset) {
      $t.autocomplete('destroy');
      _createAutocomplete($t, options);
    }
  });
};

function customizeSelect(selector, is_container, options) {
  var defsel = 'select',
      sel = selector || defsel,
      $sel = $(sel),
      opts = options || {
        autoWidth: true,
        ddMaxHeight: false,
        ddFullWidth: false,
        editable: '.editable-select',
        useSelectClasses: true
      };
  if (is_container)
    $sel = $sel.find(defsel);
  $sel.ikSelect(opts);
};

function uncustomizeSelect(selector, is_container) {
  var defsel = 'select',
      sel = selector || defsel,
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find(defsel);
  $sel.ikSelect('detach');
};

function dpikOptions() {
  var ikopts = {
    autoWidth: false,
    customClass: "calendar_select",
    ddCustomClass: "calendar_select",
    block_container: '#ui-datepicker-div'
  };
  var ikopts1 = {
    autoWidth: false,
    customClass: "tpicker_select",
    ddCustomClass: "tpicker_select",
    block_container: '#ui-datepicker-div'
  };

  return {
    beforeShow: function(input, inst) {
      var $dpdiv = $(inst.dpDiv),
          timer;

      timer = setInterval(function() {
        var $header = $dpdiv.find(".ui-datepicker-header");
            // $tp = $dpdiv.find(".ui-timepicker-div");
        if ($header.length) {
          customizeSelect($header, true, ikopts);
          // if ($tp.length) {
          //   customizeSelect($tp, true, ikopts1);
          // }
          clearInterval(timer);
        }
      }, 13);
    },
    onChangeMonthYear: function(year, month, inst) {
      var $dpdiv = $(inst.dpDiv),
          timer;

      var $header = $dpdiv.find(".ui-datepicker-header"),
          offset = $header.offset();
      $header.appendTo(document.body).css({
        "left": offset.left,
        "top": offset.top,
        "position": 'absolute',
        "z-index": 10000
      });
      timer = setInterval(function() {
        var $new_header = $dpdiv.find(".ui-datepicker-header");
        if ($new_header.length && $new_header[0] != $header[0]) {
          customizeSelect($new_header, true, ikopts);
          $header.remove();
          clearInterval(timer);
        }
      }, 13);
    }
  }
};

function setDatepicker(selector, is_container, options) {
  var sel = selector || '.datepicker',
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find('.datepicker');

  var opts = $.extend({
    showOn: 'focus',
    buttonImage: false,
    changeMonth: true,
    changeYear: true,
    yearRange: 'c-10:c+10'
    // dateFormat: 'dd.mm.yy', // Use globalize.js to format value
  }, dpikOptions());
  if (options)
    $.extend(opts, options);

  $sel.datepicker(opts);
};

function setDatetimepicker(selector, is_container, options) {
  var sel = selector || '.datetimepicker',
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find('.datetimepicker');

  var ikopts = {
    autoWidth: false,
    customClass: "tpicker_select",
    ddCustomClass: "tpicker_select",
    block_container: '#ui-datepicker-div'
  };

  var useAmpm = function(timeFormat){
    return (timeFormat.indexOf('t') !== -1 && timeFormat.indexOf('h') !== -1);
  };

  var opts = $.extend({
    showOn: 'focus',
    // controlType: 'select',
    buttonImage: false,
    changeMonth: true,
    changeYear: true,
    yearRange: 'c-10:c+10',
    // timeOnlyTitle: 'Выберите время',
    // timeText: 'Время',
    // hourText: 'Часы',
    // minuteText: 'Минуты',
    // secondText: 'Секунды',
    currentText: false,
    closeText: 'Выбрать',
    // onSelect: function(text, inst) {
    //   var $dpdiv = $(inst.inst.dpDiv),
    //       $tp = $dpdiv.find(".ui-timepicker-div");
    //   $tp.find('.ik_select select').ikSelect('detach').remove();
    //   customizeSelect($tp, true, ikopts);
    // }
    controlType: {
      create: function(tp_inst, obj, unit, val, min, max, step){
        var sel = '<select class="ui-timepicker-select" data-unit="'+ unit +'" data-min="'+ min +'" data-max="'+ max +'" data-step="'+ step +'">',
          ul = tp_inst._defaults.timeFormat.indexOf('t') !== -1? 'toLowerCase':'toUpperCase',
          m = 0;

        for(var i=min; i<=max; i+=step){
          sel += '<option value="'+ i +'"'+ (i==val? ' selected':'') +'>';
          if(unit == 'hour' && useAmpm(tp_inst._defaults.pickerTimeFormat || tp_inst._defaults.timeFormat))
            // sel += $.datepicker.formatTime("hh TT", {hour:i}, tp_inst._defaults);
            sel += $.datepicker.formatTime('hh TT', {hour:i}, tp_inst._defaults);
          else if(unit == 'millisec' || i >= 10) sel += i;
          else sel += '0'+ i.toString();
          sel += '</option>';
        }
        sel += '</select>';

        // obj.children('select').remove();
        var $s = $('select', obj);
        if ($s.data('plugin_ikSelect')) {
          $s.ikSelect('detach');
        }
        $s.remove();

        $(sel).appendTo(obj).change(function(e){
          tp_inst._onTimeChange();
          tp_inst._onSelectHandler();
        });

        if ($('#ui-datepicker-div').is(':visible') && obj.css('display') !== 'none') {
          var $s = $('select', obj);
          if (!$s.data('plugin_ikSelect')) {
            customizeSelect($s, false, ikopts);
            var $dp = $s.parent();
            $dp.find('.ik_select_block, .ik_select_list_inner, .ik_select_list_inner ul').css({
              width: 45 //$dp.find('.ik_select_list').width()
            });
          }
        }

        return obj;
      },
      options: function(tp_inst, obj, unit, opts, val){
        var o = {},
          // $t = obj.children('select');
          $t = $('select', obj);
        if(typeof(opts) == 'string'){
          if(val === undefined)
            return $t.data(opts);
          o[opts] = val;
        }
        else o = opts;
        return tp_inst.control.create(tp_inst, obj, $t.data('unit'), $t.val(), o.min || $t.data('min'), o.max || $t.data('max'), o.step || $t.data('step'));
      },
      value: function(tp_inst, obj, unit, val){
        // var $t = obj.children('select');
        var $t = $('select', obj);
        if(val !== undefined) {
          // return $t.val(val);
          $t.ikSelect("select", val);
          return $t;
        }
        return $t.val();
      }
    }
  }, dpikOptions());
  if (options)
    $.extend(opts, options);

  $sel.datetimepicker(opts);
};

function defineScreenResolution() {
  $.cookie.json = true;
  var size = $.cookie('screen_size');
  if (!size) {
    size = {
      width: screen.width,
      height: screen.height
    };
    $.cookie('screen_size', size, { expires: 364, path: '/' });
  }
  return size;
}

var ajaxCounter = 0;

function ajaxCounterInc(num) {
  ajaxCounter += num || 1;
  if (ajaxCounter > 0) {
    // temporary place indicator after h1 in top in absolute position, to fix content jumping
    var $h1 = $('.top h1');
    $('#ajax-indicator').css({
      position: 'absolute',
      top: $h1.offset().top,
      left: $h1.offset().left + $h1.width()
    })
    $('#ajax-indicator').show();
  }
  return ajaxCounter;
}

function ajaxCounterDec(num) {
  ajaxCounter -= num || 1;
  if (ajaxCounter < 0)
    ajaxCounter = 0;
  if (ajaxCounter === 0)
    $('#ajax-indicator').hide();
  return ajaxCounter;
}

$(document).ajaxStart(function() {
  ajaxCounterInc();
});
$(document).ajaxStop(function() {
  ajaxCounterDec();
});

function set_sticky_elements(selector, options) {
  selector = selector || '.sticky-element';
  if (!options) { options = {}; }
  $(selector).waypoint('sticky', options);
}

function set_waypoints(selector, options) {
  selector = selector || '.waypoint';
  var defaults = {
    offset: 100
  };
  if (!options) { options = {}; }
  options = $.extend({}, defaults, options);
  $(selector).waypoint(options);
}

function set_content_bottom_padding() {
  $('#container').css('padding-bottom', $('#footer').outerHeight());
}

function bind_settings_dialog(elements) {
  elements.dialog({
    autoOpen: false,
    modal: false,
    draggable: false,
    resizable: false,
    dialogClass: 'settings-menu-dialog',
    open: function() {
      $(':input[data-param]', this).each(function() {
        var $t = $(this);
        $t.data('current-value', $t.val());
      });
      $('.ik_select select', this).ikSelect('redraw');
    }
  });
}