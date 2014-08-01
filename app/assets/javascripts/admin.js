$(function(){
  $('.admin_companies .admin_note').each(function() {
    var docs_note_opts = $.extend({}, options, {
      template: '<div class="admin_note tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',
      placement: 'left',
      container: 'body',
      trigger: 'click'
    });
    $(this).tooltip(docs_note_opts).addClass('with_tooltip');
  });
});