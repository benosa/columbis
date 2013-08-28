/*jshint sub:true */

jQuery(function($) {

  $('.dashboard .widget-area').sortable({
    containment: '.widget-area',
    cursor: 'move',
    distance: 5,
    handle: '.widget-btn-more',
    update: function(event, ui) {
      var widgets = $(event.target).children(".widget");
      var positions = [];
      widgets.each(function() {
        positions.push($(this).attr("position"));
      });
      $.post("/boss/sort_widget", {"data": positions.toString()});
    }
  });

});