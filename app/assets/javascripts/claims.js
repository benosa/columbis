$(function(){
  // quick search
  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
    };
  })();

  $('#filter').keyup(function(){
    delay(function(){
      $.ajax({
        url: 'claims/search',
        data: { filter:$('#filter').val() },
        success: function(resp){
          $('#claims').replaceWith(resp);
        }
      });
    }, 200 );
  });

  // sort
//  $('.sort_span').click(function(event){
//    e.preventDefault();
//    $.ajax({
//      url: 'claims/search',
//      data: { filter:$('#filter').val(), sort_column:get_param('sort_column',event), sort_direction:get_param('sort_direction',event) },
//      success: function(resp){
//        $('#claims').replaceWith(resp);
//      }
//    });
//  });
});
