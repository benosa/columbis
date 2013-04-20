$(function(){

  // Get value from dom element
  function getValue(_el) {
    var $el = $(_el || document.body),
        val;
    if (typeof $el.data('value') != 'undefined')
      val = $el.data('value');
    else if (typeof $el[0].value != 'undefined')
      val = $el.val();

    return val;
  }

  // Get current filter params
  function getFilter(selector) {
    var filter = {},
        $s = $(selector || ':input[data-filter], a[data-filter].active');
    if (!$s.is('[data-param]'))
      return filter;
    $s.each(function() {
      var param, value, to_filter,
          $t = $(this);
      param = $t.data('param');
      value = getValue(this);
      to_filter = param && value && param != '' && value != '';
      if (to_filter && $t.is(':checkbox')) {
        var unchecked_value = $t.data('unchecked');
        if (unchecked_value !== undefined) {
          value = $t.prop('checked') ? value : unchecked_value;
          to_filter = true;
        } else
          to_filter = $t.prop('checked');
      }
      if (to_filter)
        filter[param] = value;
    });
    return filter;
  }

  // Get current sort params
  function getSort(selector, toggle_dir) {
    var sort = {},
        $a = $(selector || 'a.sort_active[data-sort]');
    if ($a.length && $a.is('[data-sort]')) {
      sort['sort'] = $a.data('sort');
      sort['dir'] = !toggle_dir ? $a.data('dir') : toggle_sort_dir($a.data('dir'));
    }
    return sort;
  }

  function toggle_sort_dir(dir) {
    return dir == 'asc' ? 'desc' : 'asc';
  }

  // Get current params data
  function getParamsData() {
    return $.extend({}, getFilter(), getSort());
  }
  window.getParamsData = getParamsData;

  var jqxhr;

  // Refresh current list
  function listRefresh(data, container_selector) {
    var selector = container_selector || '.current_container';
        $container = $(selector);
    if (!$container.length) return;
    var url = $container.data('url') ||  window.location.href;
    if (data === undefined || $.isEmptyObject(data)) {
      data = getParamsData();
    } else if (data === false) {
      data = {};
    }

    //ajaxCounterInc(); // move to common.js put in .ajaxStart
    // Add refreshing properties to container
    addRefreshing($container);

    if (jqxhr)
      jqxhr.abort();

    jqxhr = $.ajax({
      url: url,
      timeout: 15000, // 15 sec
      data: data,
      dataType: 'text',
      context: {
        selector: selector,
        container: $container[0]
      }
    }).done(function(resp){
        // If it is not last refresh request do nothing
        if (ajaxCounterDec() > 0)
          return;

        // replace content
        $(this.container).replaceWith(resp);

        var $container = $(this.selector),
            $content_for = $container.find('#content_for');

        // If content_for div exist, perform it's data
        if ($content_for.length) {
          var data = $content_for.data(),
              $block;
          for (block_id in data) {
            $block = $('#' + block_id);
            $block.html(data[block_id]);
            // trigger the refreshed event for current block
            $block.trigger('refreshed');
          };
          $content_for.remove();
        }

        // trigger the refreshed event
        $container.trigger('refreshed');
    }).fail(function() {
      // ajaxCounterDec(); // move to common.js put in .ajaxStop
    });
  }

  function addRefreshing($container) {
    if (!$container.data('refreshing'))
      $container.data('refreshing', true).addClass('refreshing');
  }

  function removeRefreshing($container) {
    if ($container.data('refreshing'))
      $container.removeData('refreshing').removeClass('refreshing');
  }

  // Bind callbacks on changing filter params
  function bindParams(container) {
    $(':input[data-param], a[data-param], a[data-sort]', container || document.body).filter(':not([data-event="false"])').each(function() {
      var $t = $(this),
          event = $t.data('event') || ($(this).is(':input') ? 'change' : 'click');

      $t.bind(event, function(e) {
        var $t = $(this),
            toggle_dir = $t.is('a.sort_active'),
            param = $t.data('param');

        if (e.type == 'click') {
          e.preventDefault();

          var as = 'a[data-filter][data-param=' + param + ']';
          if ($t.is(as)) {
            $(as).removeClass('active');
            $t.addClass('active');
          }
        }

        var data = $.extend(getParamsData(), getFilter(this), getSort(this, toggle_dir));

        if (e.type == 'keyup' && !e.isTrigger)
          exclusive_delay(function() {
            listRefresh(data);
          }, 200);
        else
          listRefresh(data);
      });
    });
  }

  // Exports
  window.listRefresh = listRefresh;

  // Bind handlers to all param filters on the page
  bindParams();

  // Bind handler for default actions after refresh default container
  $('body').on('refreshed', function(e) {
    // reset params changing
    bindParams(e.target);
    // reset select customization in current list container
    customizeSelect(e.target, true);
  });

});