(function() {

  // Charts object with common methods
  var Charts = {
    jqel: function(el) {
      el = el || '';
      return $((el[0] != '#' ? '#' : '') + el);
    },

    defaults: {
      'bar': {
        chart: {
          renderTo: '#default_chart',
          type: 'bar',
          spacingBottom: 15,
          spacingTop: 10,
          spacingLeft: 10,
          spacingRight: 30
        },
        title: {
          text: 'Bar chart'
        },
        subtitle: {
          text: 'default view'
        },
        credits: {
          enabled: false
        },
        plotOptions: {
          bar: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
              enabled: true
            }
          }
        },
        legend: {
          enabled: false
        },
        tooltip: {
          formatter: function() { return this.series.name + ': ' + this.y.toFixed(2); }
        }
      },

      'pie': {
        chart: {
          renderTo: '#default_chart',
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false,
          spacingBottom: 15,
          spacingTop: 10,
          spacingLeft: 30,
          spacingRight: 30
        },
        title: {
          text: 'Pie chart'
        },
        credits: {
          enabled: false
        },
        tooltip: {
          // pointFormat: '{series.name}: <b>{point.percentage}%</b>',
          formatter: function() {
            return this.point.name + ': <b>' + this.percentage.toFixed(2) + ' %</b>';
          },
          percentageDecimals: 2
        },
        plotOptions: {
          pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
              enabled: true,
              color: '#000000',
              connectorColor: '#000000',
              formatter: function() {
                return this.point.name + ': <b>' + this.percentage.toFixed(2) + ' %</b>';
              }
            }
          }
        }
      }

    }
  }

  // Chart object
  var Chart = function(type, el, options) {
    this.type = type || 'bar';
    this.$el = Charts.jqel(el);
    this.options = options || {}
    this.highchart = null;

    var defaults = $.extend(true, {}, Charts.defaults[this.type], {
      chart: {
        renderTo: this.$el.prop('id')
      }
    });

    var data = this.$el.data('chart');
    if (data) {
      try {
        data = $.parseJSON(data);
      } catch(e) { data = {} }
    }

    var settings = $.extend(true, {}, defaults, data, this.options);

    this.highchart = new Highcharts.Chart(settings);
  }

  // Extend Charts object with additional methods
  $.extend(Charts, {
    bar: function(el, options) {
      return new Chart('bar', el, options);
    },

    pie: function(el, options) {
      return new Chart('pie', el, options);
    }
  });

  window.Charts = Charts;

})();
