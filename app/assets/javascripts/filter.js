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
        param, value
        $s = $(selector || ':input[data-filter], a[data-filter].active');
    if (!$s.is('[data-param]'))
      return filter;
    $s.each(function() {
      param = $(this).data('param');
      value = getValue(this);
      if (param && value && param != '' && value != '')
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

  var jqxhr;

  // Refresh current list
  function listRefresh(data, container_selector) {
    var selector = container_selector || '.current_container';
        $container = $(selector);
    if (!$container.length) return;
    var url = $container.data('url') ||  window.location.href;
    if (typeof data == 'undefined')
       data = getParamsData();
    else if (data === false)
        data = {};

    ajaxCounterInc();

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

        $(this.container).replaceWith(resp);
        // reset params changing
        bindParams(this.selector);
        // reset select customization in current list container
        customizeSelect(this.selector, true);
    }).fail(function() {
      ajaxCounterDec();
    });
  }

  var ajaxCounter = 0;

  function ajaxCounterInc(num) {
    ajaxCounter += num || 1;
    if (ajaxCounter > 0)
      $('#ajax-indicator').show();
    return ajaxCounter;
  }

  function ajaxCounterDec(num) {
    ajaxCounter -= num || 1;
    if (ajaxCounter < 0)
      ajaxCounter = 0;
    if (ajaxCounter === 0)
      $('#ajax-indicator').hide();
    return ajaxCounter;
  }

  // Bind callbacks on changing filter params
  function bindParams(container) {
    $(':input[data-param], a[data-param], a[data-sort]', container || document.body).each(function() {
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

  bindParams();

  // Exports
  window.listRefresh = listRefresh;

});