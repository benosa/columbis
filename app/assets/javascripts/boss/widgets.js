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
  // $('.dashboard .widget-area').sortable({
  //   containment: '.widget-area',
  //   cursor: 'move',
  //   distance: 5,
  //   handle: '.widget-btn-more',
  //   update: function(event, ui) {
  //     var widgets = $(event.target).children(".widget");
  //     var positions = [];
  //     widgets.each(function() {
  //       positions.push($(this).attr("position"));
  //     });
  //     $.post("/boss/sort_widget", {"data": positions.toString()});
  //   }
  // });
  $('.dashboard .widget-area').shapeshift({
    align: 'left',
    minColumns: 3
  });
  $('.dashboard .widget-area').on("ss-rearranged", function(e, selected) {
    var widgets = $(this).children(".widget");
    var positions = [];
    widgets.each(function() {
      positions.push($(this).attr("position"));
    });
    $.post("/boss/sort_widget", {"data": positions.toString()});
  });
};

function check_widget_visible(widget_id, visible) {
  var has_visible = $("label[for='widget-" + widget_id + "']").hasClass('active');
  if (has_visible != visible) {
    change_widget_visible(widget_id, visible);
  };
};

function change_widget_visible(widget_id, visible) {
  if (visible == true) {
    $("label[for='widget-" + widget_id + "']").removeClass('false');
    $("label[for='widget-" + widget_id + "']").addClass('active');
    $("input[id='widget-" + widget_id + "']").attr("checked", "checked");
  } else {
    $("label[for='widget-" + widget_id + "']").removeClass('active');
    $("label[for='widget-" + widget_id + "']").addClass('false');
    $("input[id='widget-" + widget_id + "']").removeAttr("checked");
  };
};