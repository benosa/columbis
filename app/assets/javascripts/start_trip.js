function step_cookie_set(step) {
  var currentDate = new Date();
  expirationDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()+3, 0, 0, 0);
  $.cookie('start_trip_step', step, {expires: expirationDate});
}

$(function(){
  var step = $('html').data('start_trip_step');

  if (step == '1') {
    $(".save").bind("click", function() {
      step_cookie_set(step)
    });
  }
});