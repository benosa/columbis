// dasboard js only

$(function(){

  // dropdown filter
	var filter_table = function(event){
    $.ajax({
      url: '/dashboard/dropdown_values',
      type: 'GET',
      data:  { 'list':$(this).val() },
      cache: false,
      success: function(resp){
        $('#dropdowns').replaceWith(resp);
      }
    });
	}
	$('#list_filter').change(filter_table);

  //prepare fields
  function process($fields) {
    if ($fields.parent('.nested_attributes').hasClass('printers')) {
      if ($fields.find('.mode_select').val() == 'contract') {
        $fields.find('.country_label').hide();
        $fields.find('.country_select').hide();
      } else {
        $fields.find('.country_label').show();
        $fields.find('.country_select').show();
      }
    }
  }

	// add nested fields
  $('.nested_attributes a.add').live('click', function(e) {
		e.preventDefault();

    $fields = $(this).prev('.fields').clone(true);
    $fields.css('display', '');

    var id = parseInt(/_attributes_(\d+)/.exec($fields.find('input:first').attr('id'))[1]);
    id += 1;
    $fields.find('*').each(function (i) {
      if (!$(this).is('option')) {
        $(this).val('');
      }
      if ($(this).attr('id') != undefined) {
        $(this).attr('id', $(this).attr('id').replace(/_attributes_(\d+)/, '_attributes_' + id));
      }
      if ($(this).attr('name') != undefined) {
        $(this).attr('name', $(this).attr('name').replace(/_attributes\]\[(\d+)/, '_attributes][' + id));
      }
      if ($(this).attr('for') != undefined) {
        $(this).attr('for', $(this).attr('for').replace(/_attributes_(\d+)/, '_attributes_' + id));
      }
    });

    $(this).before($fields);
    process($fields);
	});

	// delete nested fields
  $('.nested_attributes a.remove').live('click', function(e) {
		e.preventDefault();

    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.fields').hide();
	});

  // show-hide country when mode changed
  $('.printers .mode_select').live('change', function(e) {
    $(this).closest('.fields').find('.country_label').toggle();
    $(this).closest('.fields').find('.country_select').toggle();
	});

  // select regions
	function loadRegions(country_id){
    $.ajax({
      url: '/dashboard/get_regions/' + country_id
    });
  }

  $('#countries').live('change', function(e){
    loadRegions($('#countries').val());
  });

  // select cities
  function loadCities(region_id){
    $.ajax({
      url: '/dashboard/get_cities/' + region_id
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
  $('#selected_cities a.del').live('click', function(e) {
		e.preventDefault();

    var id = $(this).attr('id').replace(/del_/, '');
    $('#tr_'+id).remove();
	});

});
