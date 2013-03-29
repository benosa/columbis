/*jshint sub:true */

jQuery(function($) {

  $('.dashboard .widget-area').sortable({
    containment: '.widget-area',
    cursor: 'move',
    distance: 5,
    // grid: [247, 213],
    handle: '.widget-btn-more'
  });

});