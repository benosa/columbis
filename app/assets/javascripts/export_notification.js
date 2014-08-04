var validNavigation = false;

function export_notification_cookie_set() {
  var currentDate = new Date();
  expirationDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()+1, 0, 0, 0);
  $.cookie('export_notification', 1, {expires: expirationDate});
}

function export_notification_f() {
  if (!validNavigation) {
    var notificated = $.cookie('export_notification');
    var message = $('body').data('export_n_message');

    if (notificated != '1') {
      export_notification_cookie_set();
      if (navigator.userAgent.search(/Firefox/) > -1) {
        alert(message);
        return 1;
      } else {
        return message;
      }
    }
  }
}

function export_notification_exit() {
  var notificated = $.cookie('export_notification');
  var message = $('body').data('export_n_message');
  if (notificated != '1') {
    export_notification_cookie_set();
    alert(message);
    return false;
  }
}

function wireUpEvents() {

  $(window).on('beforeunload', export_notification_f);

  // Attach the event keypress to exclude the F5 refresh
  $(document).bind('keypress', function(e) {
    if (e.keyCode == 116){
      validNavigation = true;
    }
  });

  // Attach the event click for all links in the page
  $("a").bind("click", function() {
    validNavigation = true;
  });

  // Attach the event submit for all forms in the page
  $("form").bind("submit", function() {
    validNavigation = true;
  });

  // Attach the event click for all inputs in the page
  $("input[type=submit]").bind("click", function() {
    validNavigation = true;
  });

}

$(function() {
  if ($('body').data('export_notification') == true) {
    wireUpEvents();
    $("#logout_link").bind("click", export_notification_exit);
  }
});