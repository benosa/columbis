$(function(){
	$('.tasks').each(function(){
		var self = $(this);

		self.find('.bug_checkbox').on('change', function(){
			var row = $(this).closest('tr');
			var task_id = this.value;
			
			$.ajax({
				type: 'POST',
				url: '/tasks/'+task_id+'/bug',
				data: {state: (this.checked) ? 1 : 0},
				dataType: 'json',
				success: function(data) {
					if (data) {
						row.addClass('bug');
					} else {
						row.removeClass('bug');
					}
				}
			});
		});
	});
});