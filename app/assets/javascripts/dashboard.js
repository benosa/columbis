// dasboard js only

$(function(){

  // select regions
	function loadRegions(country_id){
    $.ajax({
      url: '/dashboard/get_regions/' + country_id,
    });
  }

  $('#countries').live('change', function(e){
    loadRegions($('#countries').val());
  });

  // select cities
  function loadCities(region_id){
    $.ajax({
      url: '/dashboard/get_cities/' + region_id,
    });
  }

  $('#regions').live('change', function(e){
    loadCities($('#regions').val());
  });

  // add selected city
  $('a.add').live('click', function(e) {
		e.preventDefault();

    var id = $('#cities').val();
    if ($('#tr_' + id).length == 0) {
      var $tr = $('#etalon').clone(true);
      $tr.attr('id', 'tr_' + id);

      $tr.find('td:first').text($('#cities option:selected').text());
      $tr.find('a').attr('id', 'del_' + id);
      $tr.find('input[type=hidden]').attr('name', 'company[city_ids][]').val(id);

      $tr.removeAttr('style');
      $('#selected_cities').append($tr);
    }
	});


  // delete selected city
  $('a.del').live('click', function(e) {
		e.preventDefault();

    var id = $(this).attr('id').replace(/del_/, '');
    $('#tr_'+id).remove();
	});
});
