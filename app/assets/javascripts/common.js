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
      $form.submit();
  });

  // customize all selects
  customizeSelect();

  // set default date and datetime pickers
  setDatepicker();
  setDatetimepicker();

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
}

function uncustomizeSelect(selector, is_container) {
  var defsel = 'select',
      sel = selector || defsel,
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find(defsel);
  $sel.ikSelect('detach');
}

function setDatepicker(selector, is_container, options) {
  var sel = selector || '.datepicker',
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find('.datepicker');

  var opts = {
    showOn: 'focus',
    buttonImage: false,
    changeMonth: true,
    changeYear: true,
    dateFormat: 'dd.mm.yy',
    beforeShow: function(input, inst) {
      var $dpdiv = $(inst.dpDiv),
          opts = {
            autoWidth: false,
            customClass: "calendar_select",
            ddCustomClass: "calendar_select"
          },
          timer;

      if (!$dpdiv.data('_init'))
        timer = setInterval(function() {
          var $header = $dpdiv.find(".ui-datepicker-header");
          if ($header.length) {
            customizeSelect($header, true, opts);
            $dpdiv.data('_init', true);
            clearInterval(timer);
          }
        }, 13);
      else
        customizeSelect($dpdiv.find(".ui-datepicker-header"), true, opts);
    },
    onClose: function(dateText, inst) {
      var $dpdiv = $(inst.dpDiv);
      uncustomizeSelect($dpdiv.find(".ui-datepicker-header"), true);
    }
  };
  if (options)
    $.extend(opts, options);

  $sel.datepicker(opts);
}

function setDatetimepicker(selector, is_container, options) {
  var sel = selector || '.datetimepicker',
      $sel = $(sel);
  if (is_container)
    $sel = $sel.find('.datetimepicker');

  var opts = {
    showOn: 'focus',
    buttonImage: false,
    changeMonth: true,
    changeYear: true,
    timeOnlyTitle: 'Выберите время',
    timeText: 'Время',
    hourText: 'Часы',
    minuteText: 'Минуты',
    secondText: 'Секунды',
    currentText: 'Сейчас',
    closeText: 'Закрыть'
  };
  if (options)
    $.extend(opts, options);

  $sel.datetimepicker(opts);
}