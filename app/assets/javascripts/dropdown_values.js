$(function(){
	var filter_table = function(event){
    $.ajax({
      url: '/dropdown_values',
      type: 'GET',
      data:  { 'list':$(this).val() },
      cache: false,
      success: function(resp){
        $('#dropdowns').replaceWith(resp);
      }
    });
	}
	$('#list_filter').change(filter_table);
});
