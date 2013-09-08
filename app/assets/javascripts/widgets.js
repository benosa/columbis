/*jshint sub:true */
jQuery(function($) {

  bind_settings_dialog($('.widget-menu .settings-menu'));
  bind_widget_area_to_sortable();

  // Settings menu on widget open button
  $('.widget-menu a.settings').live('click', function(e) {
    e.preventDefault();
    var widget_id = $(e.target).attr('id').split('_'),
        id = widget_id[widget_id.length-1];
    $("#settings-menu-" + id)
      .dialog('option', 'position', { my: 'right top', at: 'right bottom', of: this })
      .dialog('open');
  });

  // Settings menu on widget save and close button
  $('form.edit_boss_widget .settings-menu-buttons input').live('click', function(e) {
    var widget_id = $(e.target).closest('form.edit_boss_widget').attr("id").split('_'),
        id = widget_id[widget_id.length-1];
    $("#settings-menu-" + id).dialog('close');
  });
});

function bind_widget_area_to_sortable(){
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
};