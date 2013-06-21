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
				success: function(timestamp) {
					this.set_server_time(timestamp);
					this.refresh();
				}
			});
		},

		set_server_time: function(timestamp) {
			this.server_time = parseInt(timestamp) * 1000;
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
			var timestamp = this.$el.data('timestamp');
			if (!timestamp) {
				this.load_time();
			} else {
				this.set_server_time(timestamp);
				this.refresh();
			}
		}
	}

	Clock.init();
	window.Clock = Clock;
});

