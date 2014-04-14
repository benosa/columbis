$(document).ready(function() {

 function check_refresh() {
    var refresh_timer,
        $ro = $('#refresh_operator');

    refresh_timer = setTimeout(function() {
      $.ajax({
        url: $ro.data('check-path'),
        dataType: 'json'
      })
      .fail(function() { check_refresh(); })
      .done(function(res) {
        if (res && res.working) {
          check_refresh();
        } else {
          window.location = $ro.data('check-path');
        }
      });
    }, 10000);
  }

  if ($('#refresh_operator').data('working') == true) {
    ajaxCounterInc(1);
    check_refresh();
  };
});