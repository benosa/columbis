(function() {

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

  // Charts object with common methods
  var Charts = {
    jqel: function(el) {
      el = el || '';
      return $((el[0] != '#' ? '#' : '') + el);
    },

    dateFormats: {
      default: '%d.%m.%Y',
      short: '%d.%m',
      month: '%B'
    },

    dateFormatter: function(timestamp, format) {
      format = this.dateFormats[format || 'default'] || format
      return Highcharts.dateFormat(format, timestamp, false);
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
        // subtitle: {
        //   text: 'default view'
        // },
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
      },

      'line': {
        chart: {
          renderTo: '#default_chart',
          type: 'spline',
          spacingBottom: 15,
          spacingTop: 10,
          spacingLeft: 10,
          spacingRight: 30
        },
        title: {
          text: 'Line chart'
        },
        credits: {
          enabled: false
        },
        plotOptions: {
          spline: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
              enabled: false
            },
            marker: {
              enabled: false,
              states: {
                hover: {
                  enabled: true
                }
              }
            }
          }
        },
        legend: {
          enabled: false
        },
        tooltip: {
          formatter: function() {
            var labels = [Charts.dateFormatter(this.x)];
            labels.push(this.series.name + ': ' + this.y.toFixed(2));
            return labels.join('<br/>');
          }
        }
      },

      'area': {
        chart: {
          renderTo: '#default_chart',
          type: 'area',
          spacingBottom: 15,
          spacingTop: 10,
          spacingLeft: 10,
          spacingRight: 30
        },
        title: {
          text: 'Area chart'
        },
        credits: {
          enabled: false
        },
        plotOptions: {
          series: {
            lineWidth: 1
          },
          area: {
            stacking: 'normal',
            lineWidth: 1,
            marker: {
              enabled: false,
              lineWidth: 1,
              // lineColor: '#666666'
              states: {
                hover: {
                  enabled: true
                }
              }
            }
          }
        },
        legend: {
          enabled: false,
          symbolWidth: 10
        },
        tooltip: {
          shared: true,
          formatter: function() {
            var point, i,
                labels = [Charts.dateFormatter(this.x)];
            for (i = 0; i < this.points.length; i++) {
              point = this.points[i];
              labels.push(point.series.name + ': ' + point.y.toFixed(2));
            }
            return labels.join('<br/>');
          }
        }
      },

      'funnel': {
        chart: {
          type: 'funnel',
          marginRight: 100
        },
        title: {
          text: 'Funnel chart'
        },
        plotOptions: {
          series: {
          	dataLabels: {
	          enabled: true,
	          color: 'black',
	          format: '<b>{point.name}</b> ({point.y:,.0f})',
	          softConnector: true
            },
            neckWidth: '30%',
            neckHeight: '25%'
          }
        },
        legend: {
          enabled: false
        }
      },

      'column': {
        chart: {
          renderTo: '#default_chart',
          type: 'column',
          spacingBottom: 15,
          spacingTop: 10,
          spacingLeft: 10,
          spacingRight: 30
        },
        title: {
          text: 'Column chart'
        },
        credits: {
          enabled: false
        },
        plotOptions: {
          column: {
            // stacking: 'normal',
            // dataLabels: {
            //   enabled: true,
            //   color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
            // }
          }
        },
        legend: {
          enabled: false,
          symbolWidth: 10
        },
        tooltip: {
          shared: true,
          formatter: function() {
            var point, i,
                labels = [Charts.dateFormatter(this.x)];
            for (i = 0; i < this.points.length; i++) {
              point = this.points[i];
              labels.push(point.series.name + ': ' + point.y.toFixed(2));
            }
            return labels.join('<br/>');
          }
        }
      }

    },

    datetime_defaults: {
      xAxis: {
        labels: {
          formatter: function() { return Charts.dateFormatter(this.value, 'short') }
        }
      }
    },

    list: {}, // list of chart instances

    bar: function(el, options) {
      this.list[el] = new Chart('bar', el, options);
      return this.list[el];
    },

    pie: function(el, options) {
      this.list[el] = new Chart('pie', el, options);
      return this.list[el];
    },

    line: function(el, options) {
      this.list[el] = new Chart('line', el, options);
      return this.list[el];
    },

    funnel: function(el, options) {
      this.list[el] = new Chart('funnel', el, options);
      return this.list[el];
    },

    dateline: function(el, options) {
      options = $.extend(true, {}, Charts.datetime_defaults, options);
      this.list[el] = new Chart('line', el, options);
      return this.list[el];
    },

    area: function(el, options) {
      this.list[el] = new Chart('area', el, options);
      return this.list[el];
    },

    datearea: function(el, options) {
      options = $.extend(true, {}, Charts.datetime_defaults, options);
      this.list[el] = new Chart('area', el, options);
      return this.list[el];
    },

    column: function(el, options) {
      options = $.extend(true, {
        xAxis: {
          labels: {
            formatter: function() { return Charts.dateFormatter(this.value, 'month') }
          }
        }
      }, options);
      this.list[el] = new Chart('column', el, options);
      return this.list[el];
    },

    init: function(selector) {
      $(selector || '.chart').each(function() {
        var $t = $(this),
            el = $t.attr('id'),
            type = $t.data('type'),
            settings = $t.data('settings'); // must be object caused by jQuery

        if (type && settings) {
          Charts[type](el, settings);
        }
      });
    }
  }

  window.Charts = Charts;

})();

// Onready execution
$(function() {

  // Default Hightchart options
  Highcharts.setOptions({
    lang: {
      resetZoom: 'Исходный масштаб',
      resetZoomTitle: 'Вернуть исходный масштаб 1:1',
      numericSymbols: [' т', ' м'],
      months: Globalize.cultures['ru'].calendars.standard.months.names,
      shortMonths: Globalize.cultures['ru'].calendars.standard.months.namesAbbr
    }
  });

  // Initialize all charts on the page
  Charts.init();

  // Initialize charts after container was refreshed
  $('body').on('refreshed', '.current_container', function() {
    Charts.init('.current_container .chart');
  });

  // Set date interval by period changing
  $('.filter select.period').on('change', function() {
    var period = $(this).val(),
        current_date = new Date(),
        d = current_date.getDate(),
        m = current_date.getMonth(),
        y = current_date.getFullYear(),
        start_date, end_date;

    switch (period) {
      case 'day':
        start_date = end_date = current_date;
        break;
      case 'week':
        var wd = current_date.getDay(),
            sd = wd > 0 ? wd - 1 : 6,
            ed = 6 - sd;
        start_date = new Date(y, m, d - sd);
        end_date = new Date(y, m, d + ed);
        break;
      case 'month':
        start_date = new Date(y, m, 1);
        end_date = new Date(y, m + 1, 0);
        break;
      case 'year':
        start_date = new Date(y, 1, 1);
        end_date = new Date(y, 12, 0);
        break;
    }

    if (start_date && end_date) {
      $('.filter .start_date').val(Globalize.format(start_date, 'd'));
      $('.filter .end_date').val(Globalize.format(end_date, 'd'));
      listRefresh();
    }
  });

});