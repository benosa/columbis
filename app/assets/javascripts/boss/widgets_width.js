$(function() {
  var const_width = 260;
  var widget_count = Math.floor(($('.current_container').width() + 10) / const_width);
  var widget_width = Math.floor($('.current_container').width() / widget_count);
  //alert(widget_width);
  $('.widget-small').css({
    width: widget_width
  });

  $('.widget-medium').css({
    width: widget_width * 2 + 10
  });

  $('.widget-large').css({
    width: widget_width * 4 + 30
  });
});