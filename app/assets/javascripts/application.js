// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require vendor
//= require_tree .

$(function(){
  $('input.datepicker').datepicker({ dateFormat: 'dd.mm.yy' });
  $('input.datetimepicker').datetimepicker({
    timeOnlyTitle: 'Выберите время',
    timeText: 'Время',
    hourText: 'Часы',
    minuteText: 'Минуты',
    secondText: 'Секунды',
    currentText: 'Сейчас',
    closeText: 'Закрыть'
  });

  $('.editable-select').editableSelect({
    bg_iframe: true,
    onSelect: function(list_item) {
      // alert('List item text: '+ list_item.text());
      // 'this' is a reference to the instance of EditableSelect
      // object, so you have full access to everything there
      // alert('Input value: '+ this.text.val());
    },
    case_sensitive: false, // If set to true, the user has to type in an exact
                        // match for the item to get highlighted
    items_then_scroll: 10 // If there are more than 10 items, display a scrollbar
  });

  // visa check flag
  if ($('#claim_visa_confirmation_flag').length > 0) {
    if ($('#claim_visa_confirmation_flag')[0].checked) {
      $('#claim_visa_check').datepicker('enable');
    } else {
      $('#claim_visa_check').datepicker('disable');
    }
  }

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

});
