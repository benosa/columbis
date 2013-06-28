$(function() {

	var Clock = {
		$el: $('#clock'),
		server_time: null,
		delta: 0,
		url: '/current_timestamp',
		secTimer: null,
		syncTimer: null,
		syncTimeout: 1000 * 60 * 60, // 1 hour
		format: 'HH:mm:ss',

		load_time: function() {
			$.ajax({
				url: this.url,
				context: this,
				success: function(datetime) {
					this.set_server_time(datetime);
					this.refresh();
				}
			});
		},

		// datetime format YYYY.MM.DD HH:MM:SS
		timestamp: function(datetime) {
			var parts = datetime.split(' '),
					d = parts[0].split('.'),
					t = parts[1].split(':');
			return new Date(d[0], d[1], d[2], t[0], t[1], t[2]).getTime();
		},

		set_server_time: function(datetime) {
			this.server_time = this.timestamp(datetime);
			this.delta = this.server_time - new Date().getTime();
		},

		render: function() {
			var timestamp = new Date().getTime() + this.delta,
					text = Globalize.format(new Date(timestamp), this.format);
			this.$el.html(text);
		},

		set_timers: function() {
			clearInterval(this.secTimer);
			this.secTimer = setInterval(function() { Clock.render(); }, 1000);
			clearInterval(this.syncTimer);
			this.syncTimer = setInterval(function() { Clock.load_time(); }, this.syncTimeout);
		},

		refresh: function() {
			this.render();
			this.set_timers();
		},

		init: function() {
			if (this.$el.length == 0) { return; }

			// var datetime = this.$el.data('datetime');
			// if (!datetime) {
			// 	this.load_time();
			// } else {
			// 	this.set_server_time(datetime);
			// 	this.refresh();
			// }
			this.load_time();
		}
	}

	Clock.init();
	window.Clock = Clock;
});

