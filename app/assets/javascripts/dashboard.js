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
  function process($fields, mode) {
    if ($fields.parent('.nested_attributes').hasClass('printers')) {
      mode = mode || $fields.find('.mode_select').val();
      if ($.inArray(mode, ['contract', 'warranty', 'permit', 'act']) != -1) {
        $fields.find('.country_label').hide();
        $fields.find('.country_select').hide();
      } else {
        $fields.find('.country_label').show();
        $fields.find('.country_select').show();
      }
    }
  }

	// add nested fields
  function new_nested_fields(el, id) {
    var $fields = $(el).closest('.nested_attributes').find('.fields.new_record').clone(true);
    $fields.removeClass('new_record').css('display', 'block');

    if (!id) {
      id = parseInt($fields.find('input:first').attr('id').replace(/_attributes_/, ''));
      id += 1;
    }

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
    return $fields;
  }

  $('.nested_attributes a.add').live('click', function(e) {
		e.preventDefault();
    var $fields = new_nested_fields(this);
    $(this).before($fields);
    process($fields);
	});

  function remove_nested_fields(el, only_remove) {
    if (!only_remove) {
      $(el).prev('input[type=hidden]').val('1');
      $(el).closest('.fields').hide();
    } else
      $(el).closest('.fields').remove();
  }

	// delete nested fields
  $('.nested_attributes a.remove').live('click', function(e) {
		e.preventDefault();
    remove_nested_fields(this);    
	});

  // add new file field for printer changing
  $('.printers .edit').live('click', function(e) {
    e.preventDefault();
    var $fields, $parent = $(this).closest('.fields');
    var parent_id = $parent.attr('id');

    $fields = $parent.next('#' + parent_id + '_edit');
    if (!$fields.length) {
      $fields = new_nested_fields(this, parent_id.replace(/\D+/, ''));
      $fields.attr('id', parent_id + '_edit');
      $fields.find('.mode_select').val($parent.data('mode'));      
      $fields.find('a.remove').die('click').click(function(e) {
        e.preventDefault();
        remove_nested_fields(this, true);
      });
      var $country = $parent.find('.country');
      if ($country.length)
        $fields.find('.country_select').val($country.attr('id').replace(/\D+/, ''));      
    }

    $parent.after($fields);
    process($fields);
  });

  // show-hide country when mode changed
  $('.printers .mode_select').live('change', function(e) {
    process($(this).closest('.fields'));
	});

  // select regions
	function loadRegions(country_id){
    $.ajax({
      url: '/dashboard/get_regions/' + country_id,
      success: function() {
        // reset regions select customization
        customizeSelect('#regions, #cities');        
      }
    });
  }

  $('#countries').live('change', function(e){
    loadRegions($('#countries').val());
  });

  // select cities
  function loadCities(region_id){
    $.ajax({
      url: '/dashboard/get_cities/' + region_id,
      success: function() {
        // reset cities select customization
        customizeSelect('#cities');        
      }
    });
  }

  $('#regions').live('change', function(e){
    loadCities($('#regions').val());
  });

  // add selected city
  $('a.add').live('click', function(e) {
		e.preventDefault();

    var id = $('#cities').val();
    if ($('#li_' + id).length == 0) {
      var $li = $('#etalon').clone(true);
      $li.attr('id', 'li_' + id);

      $li.find(':first').text($('#cities option:selected').text());
      $li.find('a').attr('id', 'del_' + id);
      $li.find('input[type=hidden]').attr({id: 'hid_' + id, name: 'company[city_ids][]'}).val(id);

      $li.removeAttr('style');
      $('#selected_cities').append($li);
    }
	});

  // delete selected city
  $('#selected_cities a.del').live('click', function(e) {
		e.preventDefault();

    var id = $(this).attr('id').replace(/del_/, '');
    $('#li_'+id).remove();
	});

});
