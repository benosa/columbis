$(document).ready(function(){
	var elem = $("p#clock");
	// start_time needs to take delay of ajax request and local time
	var start_time = new Date().getTime();
	elem.load({ url: '/set_time', success: local_timer(elem, start_time)});
});

function local_timer(elem, start_time) {
	var local_time = new Date().getTime();
	var server_time = (new Date("01/01/2013 " + elem.text())).getTime();
	var delay = local_time - start_time;
	var delta = local_time - (server_time - (delay / 2));
	var tick = 0;
	var is_syncing = false

	interval_id = setInterval(function() {
		tick ++;
		// Set time to form
		elem.text(Globalize.format(new Date(new Date().getTime() - delta), 'HH:mm:ss'));
		// begin sync with server every 1 hour
		if (tick > (1000 * 60 * 60)) {
			if(is_syncing == false) {
				elem.load({
					url: '/set_time',
					success: new_sync(elem, interval_id)
				});	
			}
			is_syncing = true;
		}
		// end sync with server every 1 hour
	}, 1000);
}

function new_sync(elem, interval_id) {
	// clear previous interval
	clearInterval(interval_id);
	var start_time = new Date().getTime();
	// cyclic call one method from another here does not lead to overflows since this call occurs once every hour
	local_timer(elem, start_time);
}

