jQuery ->
	$('#tourist_potential').on 'change', (e)->
    $fields = $(@).closest('.fields')
    is_potential = $(@).is(':checked')
    if is_potential
    	$fields.addClass('potential')
    else
    	$fields.removeClass('potential')