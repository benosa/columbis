$(function() {

  var fullScreen = {
    cancel: function(el) {
        var requestMethod = el.cancelFullScreen||el.webkitCancelFullScreen||el.mozCancelFullScreen||el.exitFullscreen;
        if (requestMethod) { // cancel full screen.
            requestMethod.call(el);
        } else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
            var wscript = new ActiveXObject("WScript.Shell");
            if (wscript !== null) {
                wscript.SendKeys("{F11}");
            }
        }
    },

    request: function(el) {
        // Supports most browsers and their versions.
        var requestMethod = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen || el.msRequestFullScreen;

        if (requestMethod) { // Native full screen.
            requestMethod.call(el);
        } else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
            var wscript = new ActiveXObject("WScript.Shell");
            if (wscript !== null) {
                wscript.SendKeys("{F11}");
            }
        }
        return false;
    },

    toggle: function() {
        var elem = document.body; // Make the body go full screen.
        var isInFullScreen = (document.fullScreenElement && document.fullScreenElement !== null) ||  (document.mozFullScreen || document.webkitIsFullScreen);

        if (isInFullScreen) {
            this.cancel(document);
        } else {
            this.request(elem);
        }
        return false;
    }
  };

  window.fullScreen = fullScreen;

  $('#fullscreen-link').on('click', function(e) {
    e.preventDefault();
    var $t = $(this),
        active = $t.hasClass('active'),
        text = active ? $t.data('flscr') : $t.data('flscr-cancel');

    $t.toggleClass('active').text(text);
    window.fullScreen.toggle();
  });

});