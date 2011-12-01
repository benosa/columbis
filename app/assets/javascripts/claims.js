$(function(){
  function getCurrentSortParams($curr){
    var currentParams = { sort:'id', direction:'asc', filter: '' };
    if ($curr.length > 0) {
      var href = $curr.attr('href');
      href = href.replace(/\/claims.*\?/, '');
      var params = href.split('&');
      for (var i = 0, len = params.length; i < len; i++){
        var pair = params[i].split('=');
        switch (pair[0]) {
          case 'sort':
    	      currentParams.sort = pair[1];
  	        break;
          case 'direction':
//            if ($curr.hasClass('current')) {
//              currentParams.direction = (pair[1]=='asc' ? 'desc' : 'asc'); // cause URL consist a future direction
//            } else {
              currentParams.direction = pair[1];
//            }
    	      break;
          case 'filter':
    	      currentParams.filter = pair[1];
    	      break;
        }
      }
    }
    currentParams.filter = $('#filter').val();
    return currentParams;
  }

  // load list
  function loadList(currentParams){
    $.ajax({
      url: 'claims/search',
      data: currentParams,
      success: function(resp){
        $('#claims').replaceWith(resp);
      }
    });
  }

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
      loadList(getCurrentSortParams($('#claims th a.current')));
    }, 200 );
  });

  // sort
  $('#claims th a').live('click', function(e){
    e.preventDefault();
    loadList(getCurrentSortParams($(e.currentTarget)));
  });
});
