$(document).ready(function(){
	var elem = $("p#clock");
	sync(elem);
	var sync_id = setInterval(function() {
		if (elem.text() != "") {
			local_timer(elem);
			clearInterval(sync_id);
		}
	}, 1000);
	setInterval(function() { sync(elem); }, 3600000)
});

function sync(elem) {
	setTimeout(function() {elem.load("set_time");}, 1000)
}

function local_timer(elem) {
	setInterval(function() {
		var time = new Date("01/01/2013 " + elem.text());
		time.setSeconds(time.getSeconds()+1);
		var OH = "", OM = "", OS = "";
		if (time.getHours() < 10) { OH = "0";	}
		if (time.getMinutes() < 10) {	OM = "0";	}
		if (time.getSeconds() < 10) {	OS = "0";	}
		elem.text(OH + time.getHours() + ":" + OM + time.getMinutes() + ":" + OS + time.getSeconds());
	}, 1000)
}
