$(function(){
  // show-hide country when mode changed
  $('#mode_name').on('change', 'div.ik_select', function(e) {
    var mode = $(this).find('li.ik_select_hover').find('span.ik_select_option')[0].title;
    if (mode != 'memo') {
      $('#country').hide();
    } else {
      $('#country').show();
    }
  });
});