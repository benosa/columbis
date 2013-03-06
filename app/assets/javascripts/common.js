$(function(){

  // Set Russian cultute for Globalize plugin as default
  if (window.Globalize) {
    Globalize.culture('ru');
  }

  // Toggle checked attribute for hidden checkbox by clicking on corresponding label
  $(document.body).on('click', 'label.checkbox', function(e){
    e.preventDefault();
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for'));
    $t.toggleClass('active');
    $checkbox.attr('checked', $t.hasClass('active')).trigger('change');
  });
  $('label.checkbox').each(function() { // Set initial state for label.checkbox's
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for'));
    $t[$checkbox.is(':checked') ? 'addClass' : 'removeClass']('active');
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
    var claims_path = $('#claims_link').attr('href');
    var $option = $('option:selected', this);
    location.href = $(this).val();
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
    if (form_id && $form.length)
      $form[0].submit(); // sometimes after redirecting $form.submit() don't work, maibe it's bug in jquery 1.7.1
  });

  // customize all selects
  customizeSelect();

  // set default date and datetime pickers
  setDatepicker();
  setDatetimepicker();

  // define screen resolution into browser cookie
  defineScreenResolution();

  $('.error_message.input_wrapper').each(function() {
    var $t = $(this),
        errors = $t.attr('title'),
        $i = $t.find(':input');
    if (errors.length) {
      if ($i.data('errors-text') === false) {
        $t.tooltip();
        return;
      }
      $t.css('width', $t.width());
      var $ell = $('<div class="errors ellipsis">' + errors + '</div>').appendTo($t);
      $ell.dotdotdot({ wrap: 'letter' });
      if ($ell.triggerHandler("isTruncated"))
        $t.tooltip();
      else
        $t.attr('title', '');
    }
  });

  $('label.required').tooltip();

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

  // Settings menu
  $('#settings-menu').dialog({
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
    }
  });

  // Settings menu open button
  $('#settings').on('click', function() {
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

});

function customizeSelect(selector, is_container, options) {
  var defsel = 'select',
      sel = selector || defsel,
      $sel = $(sel),
      opts = options || {
        autoWidth: true,
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

  return {
    beforeShow: function(input, inst) {
      var $dpdiv = $(inst.dpDiv),
          timer;

      timer = setInterval(function() {
        var $header = $dpdiv.find(".ui-datepicker-header");
        if ($header.length) {
          customizeSelect($header, true, ikopts);
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

  var opts = $.extend({
    showOn: 'focus',
    buttonImage: false,
    changeMonth: true,
    changeYear: true,
    yearRange: 'c-10:c+10',
    timeOnlyTitle: 'Выберите время',
    timeText: 'Время',
    hourText: 'Часы',
    minuteText: 'Минуты',
    secondText: 'Секунды',
    currentText: 'Сейчас',
    closeText: 'Закрыть'
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
  if (ajaxCounter > 0)
    $('#ajax-indicator').show();
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
