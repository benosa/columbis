// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
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
});
