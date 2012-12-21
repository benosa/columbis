$(function(){

  // Toggle checked attribute for hidden checkbox by clicking on corresponding label
  $("label.checkbox").on('click', function(e){
    e.preventDefault();
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for'));
    $t.toggleClass('active');
    $checkbox.attr('checked', $t.hasClass('active')).trigger('change');
  }).each(function() { // Set initial state for label.checkbox's
    var $t = $(this),
        $checkbox = $('#' + $t.attr('for'));
    $t[$checkbox.is(':checked') ? 'addClass' : 'removeClass']('active');
  });

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
    yearRange: 'c-10:c+10',
    dateFormat: 'dd.mm.yy',
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