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

  // Refresh current list
  function listRefresh(data, container_selector) {
    var selector = container_selector || '.current_container';
        $container = $(selector);
    if (!$container.length) return;
    var url = $container.data('url') ||  window.location.href;
    if (typeof data == 'undefined')
       data = getParamsData();
    $.ajax({
      url: url,
      data: data,
      dataType: 'text',
      context: {
        selector: selector,
        container: $container[0]
      },
      success: function(resp){
        $(this.container).replaceWith(resp);
        // reset params changing
        bindParams(this.selector);
        // reset select customization in current list container
        customizeSelect(this.selector, true);
      }
    });
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

        if (e.type == 'keyup')
          exclusive_delay(function() {
            listRefresh(data);
          }, 300);
        else
          listRefresh(data);
      });
    });
  };

  bindParams();

});