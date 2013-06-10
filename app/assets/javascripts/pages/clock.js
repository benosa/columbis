$(document).ready(function(){
	var elem = $("p#clock");
	sync_clock(elem);
	local_timer(elem);
	setInterval(function() { sync_clock(elem); }, 3600000)
});

function sync_clock(elem) {
	setTimeout(function() {elem.load('/set_time');}, 1000)
}

function local_timer(elem) {
	setInterval(function() {
		var time = new Date("01/01/2013 " + elem.text());
		time.setSeconds(time.getSeconds()+1);
		elem.text(Globalize.format(time, 'HH:mm:ss'));
	}, 1000)
}
