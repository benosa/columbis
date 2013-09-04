// search
function getCurrentParams(el){
  var currentParams = { sort:'reservation_date', dir:'desc', filter: '' },
      $current_sort = $('#claims th a.sort_active'),
      $el = $(el),
      href;

  if ($el.is('#claims th a')) {
    href = $el.attr('href');
  } else {
    // href = $current_sort.attr('href');
    href = 'sort=' + $current_sort.data('sort') + '&dir=' + $current_sort.data('dir'); // temporary for old sorting
  }

  if (href) {
    href = href.replace(/\/claims.*\?/, '');
    var params = href.split('&');
    for (var i = 0, len = params.length; i < len; i++){
      var pair = params[i].split('=');
      switch (pair[0]) {
        case 'sort':
          currentParams.sort = pair[1];
          break;
        case 'dir':
          if ($el[0] == $current_sort[0]) {  // change direction for current sort column
            currentParams.dir = (pair[1]=='asc' ? 'desc' : 'asc');
          } else {
            currentParams.dir = pair[1];
          }
          break;
        case 'filter':
          currentParams.filter = pair[1];
          break;
      }
    }
  }

  if ($('#office_id').length > 0 && $('#user_id').length > 0) {
    currentParams.office_id = $('#office_id').val();
    currentParams.user_id = $('#user_id').val();
  } else if ($('#only_my').length > 0) {
    currentParams.only_my = ($('#only_my')[0].checked ? '1' : '');
  }
  if ($('#only_active').length > 0) {
    currentParams.only_active = ($('#only_active')[0].checked ? '1' : '');
  }
  currentParams.filter = $('#filter').val();
  currentParams.list_type = $('#view_switcher').val();

  return currentParams;
}

function loadClaims(options) {
  var defaults = {
    url: 'claims',
    data: {},
    success: function(resp) {
      $('#claims_body .waypoint').waypoint('destroy');

      $('.claims').replaceWith(resp);

      setTitles();
      set_editable_bonus_percent();
      set_claims_sticky_header();
      set_claims_waypoint();
      set_claims_tooltip();
    }
  };
  if (!options) { options = {}; }
  options = $.extend({}, defaults, options);

  $.ajax(options);
}

// load list
function loadList(currentParams){
  loadClaims({
    data: currentParams
  });
}

// load totals
function loadTotals(data){
  loadClaims({
    url: 'claims/totals',
    data: currentParams
  });
}

// load claims by scroll
function loadClaimsByScroll(data){
  loadClaims({
    url: 'claims/scroll',
    data: data,
    success: function(resp){
      var $w = $('#claims_body .waypoint');
      $w.waypoint('destroy'); $w.remove();
      $('#claims_body .total').addClass('active');

      $('#claims_body').append(resp);

      set_claims_sticky_header();
      set_claims_waypoint();
      setTitles();
      set_editable_bonus_percent();
      remove_duplicated_totals();
      set_claims_tooltip();
    }
  });
}

function setFilters(el, inverse_sorting) {
  var val = $('#total_years').val();
  // If total filter is set, then office_id and user_id filter totals
  if (val && val.length > 0 && $(el).is('#total_years, #office_id, #user_id')) {
    var data = { year: $('#total_years').val() },
        filter = getCurrentParams(el);
    for (var p in filter)
      if ($.inArray(p, ['office_id', 'user_id']) != -1)
        data[p] = filter[p];
    loadTotals(data);
  } else
    loadList(getCurrentParams(el));
}

function setTitles() {
  // Set title attribute for all tags in claim list with full_value attribute
  $('#claims [full_value][title!=""]').each(function() {
    $(this).attr('title', $(this).attr('full_value'));
  });
}

// Set editable fields
function set_editable_bonus_percent(selector) {
  $('.bonus_percent .best_in_place:not(.active)').addClass('active').best_in_place().bind('ajax:success', function(event, jstr) {
    var json = $.parseJSON(jstr),
        bip = $(this).data('bestInPlaceEditor');
    bip.original_content = json.bonus_percent;
    $(this).html(json.bonus_percent).attr("data-original-content", json.bonus_percent);
    $(this).closest('.row').find('.bonus').html(json.bonus);
  });
}

function set_claims_waypoint() {
  set_waypoints('#claims_body .waypoint:last', {
    continuous: false,
    offset: 'bottom-in-view',
    handler: function(direction) {
      if (direction == 'down') {
        if ($(this).closest('.refreshing').length) { return; }
        var $t = $(this),
            cols = $('#claims_body tr:first td').length,
            page = parseInt($t.data('page'));
        if (isNaN(page)) { page = 2 };
        $t.addClass('active').append('<td colspan="' + cols + '" />');
        var data = $.extend({}, getCurrentParams(), { page: page });
        loadClaimsByScroll(data);
      }
    }
  });
}

function set_claims_sticky_header() {

  function fill_stuck($claims_header, $stuck) {
    var css_props = ['width', 'height',
          'border-top-width', 'border-right-width', 'border-bottom-width', 'border-left-width',
          'border-top-style', 'border-right-style', 'border-bottom-style', 'border-left-style',
          'border-top-color', 'border-right-color', 'border-bottom-color', 'border-left-color',
          'background-image', 'background-position', 'background-color', 'background-repeat',
          'padding-top', 'padding-right', 'padding-bottom', 'padding-left'
        ],
        css_a_props = ['display', 'text-align', 'text-shadow', 'color',
          'font-size', 'font-weight',
          'margin-top', 'margin-right', 'margin-bottom', 'margin-left'
        ];

    $claims_header.find('th').each(function(index) {
      var css = {}, css_a = {}, prop, i,
          $a = $(this).find('a');

      for (i in css_props) {
        prop = css_props[i];
        css[prop] = $(this).css(prop);
        css_a[prop] = $a.css(prop);
      }
      css['float'] = 'left';
      css['width'] = parseInt(css['width']) + 1;
      if (index > 0) {
        css['border-left'] = 'none';
      }

      for (i in css_a_props) {
        prop = css_a_props[i];
        css_a[prop] = $a.css(prop);
      }

      var $div = $('<div>').css(css),
          $a1 = $a.clone(true, true).css(css_a);
      $stuck.append($div.append($a1));
    });
  }

  function adjust_stuck($claims_header, $stuck) {
    var $divs = $stuck.find('div'),
        full_width = 0;
    $claims_header.find('th').each(function(index) {
      // $divs.eq(index).css('width', parseInt($(this).css('width')) + 1);
      var w = $(this).outerWidth();
      full_width += w;
      $divs.eq(index).css('width', w - 1);
    });
    $stuck.css('width', full_width + 1);
  }

  var $claims_header = $('#claims .claims_header'),
      $thead = $claims_header.closest('thead'),
      $stuck = $thead.find('.stuck');

  if ($stuck.length == 0) {
    $stuck = $('<div class="stuck"></div>');
    $stuck.css('width', $claims_header.outerWidth() + 1);
    fill_stuck($claims_header, $stuck);
    $stuck.appendTo($thead);
  }

  adjust_stuck($claims_header, $stuck);

  // Initialization
  if (!$claims_header.data('waypointsWaypointIds')) {
    set_waypoints('#claims .claims_header', {
      offset: function() { return -$(this).height(); },
      handler: function(direction) {
        var $thead = $(this).closest('thead');
        if (direction == 'down') {
          $thead.addClass('stuck_active');
        } else {
          $thead.removeClass('stuck_active');
        }
      }
    });

    $(window).on('scroll.claims', function() {
      $('#claims .stuck').css({
        top: $(this).scrollTop()
      });
    });
  }
}

function remove_duplicated_totals() {
  $('#claims_body .total:not(.active)').each(function() {
    var $t = $(this),
        date = $t.data('date');
    if ($('#claims_body .total.active[data-date="' + date + '"]').length) {
      $t.remove();
    }
  });
}

function set_claims_tooltip(init) {
  var options = {
    template: '<div class="tooltip claims_tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',
    placement: 'bottom',
    container: 'body',
    delay: 300,
    animation: false,
    trigger: 'manual'
  };
  $('#claims td[title], #claims td span[title]').each(function() {
    if (!$(this).hasClass('with_tooltip')) {
      if ($(this).is('.docs_note')) {
        var docs_note_opts = $.extend({}, options, {
          template: '<div class="tooltip claims_tooltip docs_note"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',
          placement: 'left'
        });
        $(this).tooltip(docs_note_opts).addClass('with_tooltip');
      } else {
        $(this).tooltip(options).addClass('with_tooltip');
      }
    }
  });

  if (init) {
    $('body').on('click', '#claims .with_tooltip', function(e) {
      $(this).tooltip('toggle');
    }).on('mouseout', '#claims .with_tooltip', function(e) {
      $(this).tooltip('hide');
    });
  }
}

$(function(){
  var VISA_STATUSES = ['nothing_done', 'docs_got', 'docs_sent', 'visa_approved', 'all_done'];

  function trim(str) {
     return str.replace(/^\s+|\s+$/g, '');
  }

  // dates colors
  $('#claim_arrival_date').change(function(e){
    $('#claim_depart_to').val($('#claim_arrival_date').val());
  });

  $('#claim_departure_date').change(function(e){
    $('#claim_depart_back').val($('#claim_departure_date').val());
  });

  // documents colors
  $('#claim_documents_status').change(function(e) {
    var $t = $(this),
        value = $t.val()
        $ikselect = $t.closest('.ik_select'),
        $block = $ikselect.find('.ik_select_block'),
        statuses = DOCUMENTS_STATUSES.join(' ');
    $block.removeClass(statuses).addClass(value);
    $ikselect.removeClass(statuses).addClass(value);
    $ikselect[value != 'all_done' ? 'addClass' : 'removeClass']('error');
  });

  function check_route_memo(){
   if($('#claim_memo_tasks_done')[0].checked){
      $('#claim_memo, .has_notes_ind').removeClass('red_back');
      $('#claim_memo, .has_notes_ind').addClass('blue_back');
    } else {
      $('#claim_memo, .has_notes_ind').removeClass('blue_back');
      if(trim($('#claim_memo').val()) === ''){
        $('#claim_memo, .has_notes_ind').removeClass('red_back');
        $('.has_notes_ind').addClass('blue_back');
        $('.has_notes_ind').text('Нет');
      } else {
        $('#claim_memo, .has_notes_ind').addClass('red_back');
        $('.has_notes_ind').text('Да');
      }
    }
  }
  $('#claim_memo, #claim_memo_tasks_done').change(check_route_memo);

  if($('#claim_memo_tasks_done').length > 0) {
    check_route_memo();
  }

  // operator confirm check flag
  $('#claim_operator_confirmation_flag').change(function(e){
    if ($(this).is(':checked')) {
      $('#claim_operator_confirmation').addClass('blue_back required').removeClass('red_back');
      $('label[for=claim_operator_confirmation]').addClass('required').tooltip({ title: function() { return $(this).data('required-title'); } });
    } else {
      $('#claim_operator_confirmation').removeClass('blue_back required').addClass('red_back');
      $('label[for=claim_operator_confirmation]').removeClass('required').tooltip('destroy');
    }
  });

  $('#claim_visa_status').change(function(e) {
    var status = $(this).val(),
        visa_confirmation_flag = status !== 'unrequired';
    $('#claim_visa').val(status);
    $('#claim_visa_confirmation_flag').attr('checked', visa_confirmation_flag);
    var $visa_check = $('#claim_visa_check');
    $visa_check.removeClass(VISA_STATUSES.join(' ')).addClass(status);
    if (visa_confirmation_flag) {
      $visa_check.datepicker('enable');
    } else {
      $visa_check.val('').datepicker('disable');
    }
  });

  // $('#claim_visa_confirmation_flag').change(function(e){
  //   var val = $('#claim_visa').val(),
  //       initial_status = VISA_STATUSES[0],
  //       done_status = VISA_STATUSES[VISA_STATUSES.length - 1];
  //   $('#claim_visa_check').removeClass(val);
  //   if (this.checked) {
  //     $('#claim_visa_check').removeClass(done_status).addClass(initial_status).datepicker('enable');
  //     $('#claim_visa').val(initial_status);
  //     $('#claim_visa_status').ikSelect('enable').ikSelect('select', initial_status);
  //   } else {
  //     $('#claim_visa_check').removeClass(VISA_STATUSES.join(' ')).addClass(done_status).val('').datepicker('disable');
  //     $('#claim_visa').val(done_status);
  //     $('#claim_visa_status').ikSelect('disable').ikSelect('select', initial_status);
  //   }
  // });

  // set initial state for visa fields
  // $('#claim_visa_confirmation_flag').triggerHandler('change');

  // td click full value
  $('#claims td').live('click', function(e){
    $('#full_value').val($(this).attr('full_value'));
  });

  // check date color
  $('#claim_check_date, #claim_closed').live('change', function(e){
    $('#claim_check_date').removeClass('departed hot soon');

    if ($('#claim_closed')[0].checked) {
      $('#claim_check_date').addClass('departed');
      return;
    } else if ($('#claim_check_date').val() === '') {
      $('#claim_check_date').addClass('hot');
      return;
    }

    var currentDate = new Date();
    var check_date_arr = $('#claim_check_date').val().split('.');
    var d, m, y;

    d = parseInt(check_date_arr[0])-1; // we want to get two day before...
    m = parseInt(check_date_arr[1])-1;
    y = parseInt(check_date_arr[2]);

    if (isNaN(d) || isNaN(m) || isNaN(y)) {
      $('#claim_check_date').addClass('hot');
      return;
    }

    var check_date = new Date(y, m, d);

    if(check_date <= currentDate) {
      $('#claim_check_date').addClass('hot');
    } else {
      $('#claim_check_date').addClass('soon');
    }
  });

  //  operator_price_currency change
  $('#claim_operator_price_currency').change(function(){
    var currency = $('option:selected', this).html(),
        $active_fields = $('#payments_out .fields:not(.disabled)');
    $active_fields.find('.operator_currency').html(currency);
    $('#payments_out .operator_debt_currency').html(currency);
  });

  // closed
  $('#claim_closed').click(function(e) {
    this.checked ? $('#claim_check_date').removeClass('red_back') : $('#claim_check_date').addClass('red_back');
  });

  // green lamp
  $('#claim_early_reservation').change(function(){
    if (this.checked) {
      $('.lamp_block').css('background-position','top left');
    } else {
      $('.lamp_block').css('background-position','0% -36px');
    }
  });

  // tour price
  function course(currency) {
    var value;
    switch (currency) {
      case 'eur':
        value = parseFloat($('#claim_course_eur').val());
        break;
      case 'usd':
        value = parseFloat($('#claim_course_usd').val());
        break;
    }
    value = value && isFinite(value) ? value : 1;
    return value;
  }

  function update_calculation() {
    if ($('#claim_calculation').val() === '' || /\*$/.test($('#claim_calculation').val())) {
      var str = '';
      var count = '';
      var val = parseFloat($('#claim_primary_currency_price').val());
      if (isFinite(val)) {
        str = str + val + 'rur = ';

        if ($('#claim_tour_price_currency').val() != 'rur'){
          cour = parseFloat($('#claim_course_' + $('#claim_tour_price_currency').val()).val());
          if (isFinite(cour) && cour > 0) {
            total_in_curr = Math.round(val / cour);
            str = str + total_in_curr + $('#claim_tour_price_currency').val() + ' = ';
          }
        }

        val = parseFloat($('#claim_tour_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_tour_price_currency').val() + '(тур) + ';
        }

        count = $('#claim_visa_count').val();
        if (count > 0) {
          val = parseFloat($('#claim_visa_price').val());
          if (isFinite(val) && val*count > 0) {
            str = str + count + 'x' + val + $('#claim_visa_price_currency').val() + '(визы) + ';
          }
        }

        count = $('#claim_children_visa_count').val();
        if (count > 0) {
          val = parseFloat($('#claim_children_visa_price').val());
          if (isFinite(val) && val*count > 0) {
            str = str + count + 'x' + val + $('#claim_children_visa_price_currency').val() + '(визы детск.) + ';
          }
        }
          count = $('#claim_insurance_count').val();
        if (count > 0) {
          val = parseFloat($('#claim_insurance_price').val());
          if (isFinite(val) && val*count > 0) {
            str = str + count + 'x' + val + $('#claim_insurance_price_currency').val() + '(страховка) + ';
          }
        }

        count = $('#claim_additional_insurance_count').val();
        if (count > 0) {
          val = parseFloat($('#claim_additional_insurance_price').val());
          if (isFinite(val) && val*count > 0) {
            str = str + count + 'x' + val + $('#claim_additional_insurance_price_currency').val() + '(страховка доп.) + ';
          }
        }

        count = $('#claim_fuel_tax_count').val();
        if (count > 0) {
          val = parseFloat($('#claim_fuel_tax_price').val());
          if (isFinite(val) && val*count > 0) {
            str = str + count + 'x' + val + $('#claim_fuel_tax_price_currency').val() + '(топл. сбор) + ';
          }
        }

        val = parseFloat($('#claim_additional_services_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_additional_services_price_currency').val() + '(' +
          $('#claim_additional_services').val() + ') + ';
        }

        if (str !== '') {
          $('#claim_calculation').val(str.slice(0, -2) + '*');
        }
      }
    }
  }

  var calculate_tour_price = function(){
    // we must set 0 if user left empty field after editing
    var fields =  '#claim_tour_price, #claim_additional_services_price, #claim_visa_price, #claim_children_visa_price, ' +
                  '#claim_insurance_price, #claim_additional_insurance_price, #claim_fuel_tax_price';

    $(fields).each(function(){
      var val = parseFloat($(this).val());
      if (!isFinite(val)) {
        $(this).val(0);
      }
    });

    var sum_price = parseFloat($('#claim_tour_price').val()) * course($('#claim_tour_price_currency').val());
    sum_price = sum_price +
      parseFloat($('#claim_additional_services_price').val()) * course($('#claim_additional_services_price_currency').val());

    // some fields are calculated per person
    fields =  ['#claim_visa_price', '#claim_children_visa_price', '#claim_insurance_price', '#claim_additional_insurance_price', '#claim_fuel_tax_price'];


    var total = 0;
    for(var i=0; i<fields.length; i++)  {
      var basis = fields[i].replace(/_price$/, '');
      var count = parseFloat($(basis + '_count').val());
      if (isFinite(count) && count > 0) {
        total = total + parseFloat($(fields[i]).val()) * count * course($(fields[i] +'_currency').val());
      }
    }
    sum_price = Math.round(sum_price + total);

    return sum_price;
  };

  function save_tour_price(tour_price) {
    tour_price = tour_price || calculate_tour_price();
    $('#claim_primary_currency_price').data('tour_price', tour_price);
  }

  function adjust_calculation() {
    var tour_price = calculate_tour_price(),
        prev_tour_price = $('#claim_primary_currency_price').data('tour_price');
    if (tour_price != prev_tour_price) {
      $('#claim_primary_currency_price').val(tour_price);
      $('.primary_currency_price_view').text(tour_price);
      $('#claim_primary_currency_price').change();
      calculate_tourist_debt();
      update_calculation();
      save_tour_price(tour_price);
    }
  };

  $('#claim_course_eur, #claim_course_usd, #tour_price input').bind('keyup, input', function(){
    adjust_calculation();
  });

  $('#tour_price select').change(function(){
    adjust_calculation();
  });

  // Change currency in tour_price block
  $('#claim_tour_price_currency').on('change', function() {
    var currency = $(this).val();
    $('#tour_price [id$="_price"]').not('#claim_tour_price').each(function() {
      var val = parseFloat($(this).val());
      if (!val) {
        var id = $(this).attr('id'),
            $el = $('#tour_price #' + id + '_currency');
        if ($el.ikSelect) {
          $el.ikSelect('select', currency);
        } else {
          $el.val(currency);
        }
      }
    });
  });

  // city, resort, flights
  $('#claim_city').change(function(){
    if($('#claim_airport_to').val() === '') {
      $('#claim_airport_to').val($('#claim_city').val());
    }
  });

  $('#claim_resort').change(function(){
    if($('#claim_airport_back').val() === '') {
      $('#claim_airport_back').val($('#claim_resort').val());
    }
  });

  // amount in word
	function create_data_string($elem){
	  var amount = 0, currency = '';
	  if(/^claim_payments_.{2,3}_attributes_\d+_(amount|currency)/.test($elem.attr('id'))){
	    // trying to find curr in row
      amount = $elem.closest('.fields').find('input.amount').val();
      // currency = $elem.closest('fields').find('select.currency').val();
      currency = 'rur';
	  } else {
	    // take curr from Tour Price block
	    amount = $('#claim_primary_currency_price').val();
      // TODO make ajax loading for PROAMRY_CURRENCY
      currency = 'rur';
	  }
	  return "amount=" + amount + ";currency=" + currency;
	}

	var get_amount_in_word = function(event){
    $.ajax({
      url: "/amount_in_word",
      type: "POST",
      data: create_data_string($(event.currentTarget)),
      cache: false,
      success: function(resp){
        if(/^claim_payments_.{2,3}_attributes_\d+_(amount|currency)/.test($(event.currentTarget).attr('id'))){
          $(event.currentTarget).closest('.fields').find('.description').val(resp);
        }
        else {
          $('#price_as_string').val(resp);
        }
      }
    });
	};

  var calculate_tourist_debt = function(){
    var price = parseFloat($('#claim_primary_currency_price').val());
    if (isNaN(price)) { price = 0 }
    var paid = 0.0;
    $('#payments_in .fields').not('.destroyed').each(function (i) {
      var val = parseFloat($('#claim_payments_in_attributes_' + i + '_amount').val());
      if (!isNaN(val)) {
        paid += val;
      }
    });
    $('#claim_tourist_debt').val((price - paid).toFixed(2));
  };

  var calculate_operator_debt = function(){
    var price = parseFloat($('#claim_operator_price').val());
    if (isNaN(price)) { price = 0 }
    var paid = 0.0;
    $('#payments_out .fields').not('.destroyed').each(function (i) {
      var val = parseFloat($('#claim_payments_out_attributes_' + i + '_amount_prim').val());
      if (!isNaN(val)) {
        paid += val;
      }
    });
    // var operator_debt = price - paid;
    // if (operator_debt < 0) { operator_debt = 0; }
    $('#claim_operator_debt').val(price - paid.toFixed(2));
  };

  $('#claim_operator_price').on('keyup', calculate_operator_debt);

  var calculate_amount_or_course = function(el) {
    var $el = $(el),
        $fields = $el.closest('.fields'),
        $course = $('input.course', $fields),
        course = parseFloat($course.val()),
        amount = parseFloat($('input.amount', $fields).val()),
        amount_prim = parseFloat($('input.amount_prim', $fields).val());
    if (isNaN(course) || course < 0) { course = 0; }
    if (isNaN(amount)) { amount = 0; }
    if (isNaN(amount_prim)) { amount_prim = 0; }

    if ($el.is('.course')) {
      if (amount_prim && course) {
        amount = (course * amount_prim).toFixed(2);
        $('input.amount', $fields).val(amount);
      } else if (amount && course) {
        amount_prim = course > 0 ? (amount / course).toFixed(2) : '0.00';
        $('input.amount_prim', $fields).val(amount_prim);
      }
    } else if ($el.is('.amount_prim')) {
      if (!$course.data('changing') && course && amount_prim) {
        amount = (course * amount_prim).toFixed(2);
        $('input.amount', $fields).val(amount);
      } else if (amount && amount_prim) {
        course = amount_prim > 0 ? (amount / amount_prim).toFixed(2) : '';
        $('input.course', $fields).val(course);
      }
    } else if ($el.is('.amount')) {
      if (!$course.data('changing') && course && amount) {
        amount_prim = course > 0 ? (amount / course).toFixed(2) : '0.00';
        $('input.amount_prim', $fields).val(amount_prim);
      } else if (amount_prim && amount) {
        course = amount_prim > 0 ? (amount / amount_prim).toFixed(2) : '';
        $('input.course', $fields).val(course);
      }
    }
  };

  $('#payments_in').on('keyup', 'input.amount', function(event){
    get_amount_in_word(event);
  	calculate_tourist_debt();
  });

  $('#payments_out').on('keyup', 'input.amount_prim, input.course, input.amount', function(event){
    calculate_amount_or_course(event.currentTarget);
  	calculate_operator_debt();
  });

  $('#payments_out').on('focusin focusout', 'input.amount_prim, input.amount', function(event) {
    var $el = $(event.currentTarget),
        $fields = $el.closest('.fields'),
        $course = $('input.course', $fields);
    if (event.type == 'focusin') {
      var course = parseFloat($course.val());
      if (isNaN(course) || course < 0) { course = 0; }
      if (!course) {
        $course.data('changing', true);
      }
    } else {
      $course.data('changing', false);
    }
  });

  $('#payments_in, #payments_out').on('change', 'input.approved', function(e) {
    var $t = $(this),
        $fields = $t.closest('.fields'),
        checked = $t.is(':checked');
    if (checked) {
      $fields.addClass('disabled');
      $fields.find(':input:not(.approved)').attr('readonly', checked);
      $fields.find('.datepicker').datepicker('destroy');
      $fields.find('.ik_select select').ikSelect('disable').attr('disabled', false);
      $fields.find('.operator_currency').addClass('disabled');
    } else {
      $fields.removeClass('disabled');
      $fields.find(':input:not(.approved)').attr('readonly', checked).attr('disabled', false);
      setDatepicker($fields.find('.datepicker'));
      $fields.find('.ik_select select').ikSelect('enable');
      $fields.find('.operator_currency').removeClass('disabled');
    }
  });

  $('#claim_primary_currency_price').change(get_amount_in_word);

  // autocomplete
  var select_tourist = function(el, data) {
    var $row = $(el).closest('.fake_row'),
        data = data || {};
    $.each(['passport_series', 'passport_number', 'date_of_birth', 'passport_valid_until'], function() {
      $row.find('input.' + this).val(data[this]);
    });
    if($row.hasClass('applicant')) {
      $row.find('.phone_number').val(data.phone_number);
      $row.find('.email').val(data.email);
      $row.find('.address').val(data.address);
    }
    $row.find('.hidden_id').val(data.id);
  };

  setAutocomplete('.full_name.autocomplete', false, {
    select: function(event, ui) { select_tourist(this, ui.item); }
  });

  var resort_source = function(el, country) {
    var data = $(el || '.resort.autocomplete').data('ac');
    return data ? data.source + '/' + country : '';
  };

  setAutocomplete('.country.autocomplete', false, {
    select: function(event, ui) {
      var $resort = $('.resort.autocomplete');
      $resort.autocomplete('option', 'source', resort_source($resort, ui.item.id));
      if ($(this).data('val') != ui.item.value)
        $resort.val('');
    },
    change: function(event, ui) {
      $(this).data('val', this.value);
      var $resort = $('.resort.autocomplete');
      $resort.val('').autocomplete('option', 'source', resort_source($resort, this.value));
    }
  });
  setAutocomplete('.resort.autocomplete', false , {
    source: resort_source(false, $('#claim_country_name').data('id'))
  });

  // setAutocomplete('.city.autocomplete', false , {
  //   select: function(event, ui) {
  //     $('#claim_city_id').val(ui.item.id);
  //   }
  // });

  // Set autocomplete for others autocompletes in the form
  setAutocomplete('.edit_page', true);

  // add tourist
  var add_tourist = function(tourist_block) {
    var $block = $(tourist_block),
        $last_fields = $block.find('.dependent:last'),
        num = $last_fields.length > 0 ? parseInt($last_fields.attr('id').replace(/dependent-/, ''), 10) + 1 : 0,
        tourist, html;

    tourist = {
      num: num,
      full_name: '',
      id: '',
      _destroy: '',
      date_of_birth: '',
      passport_series: '',
      passport_number: '',
      passport_valid_until: '',
    }
    html = JST['claims/dependent'].render(tourist);

    $block.find(' .add_row').before(html);

    var $fields = $block.find('.fields:last');
    setDatepicker($fields, true);
    setAutocomplete($fields.find('.full_name.autocomplete'), false, {
      select: function(event, ui) { select_tourist(this, ui.item); }
    });
  }
  $('#tourists').on('click', 'a.add', function(e) {
    e.preventDefault();
    var $t = $(this);
    add_tourist($t.closest('.form_block'));
  });

  // del tourist
  var del_tourist = function(fields){
    var $fields = $(fields);

    if ($fields.hasClass('applicant'))
      $fields.find(':input').val('');
    else {
      $fields.find('.datepicker').datepicker('destroy');
      // $fields.find('.autocomplete').autocomplete('destroy'); // this line is a cause of freezing, maybe it's a bug in jquery-ui
      $fields.find('._destroy').val('1');
      $fields.addClass('destroyed').hide();
    }
  };
	$('#tourists').on('click', 'a.delete', function(e) {
    e.preventDefault();
    var $t = $(this),
        $fields = $t.closest('.fields');

    var is_empty_fields = !$fields.find(':input[value!=""]').length;
    if (is_empty_fields || confirm($t.data('check'))) {
      del_tourist($fields);
    }
  });

  //Flights
  // add flight function
  var add_flight = function(flight_block) {
    var $block = $(flight_block),
        num = $block.find('div.flight').length,
        html;

    html = JST['claims/flight'].render({num: num});

    $block.find(' .add_row').before(html);

    setDatetimepicker($block, true);
    setAutocomplete($block, true);
  }
  // click to add flight
  $('#flights').on('click', 'a.add', function(e) {
    e.preventDefault();
    var $t = $(this);
    add_flight($t.closest('.form_block'));
  });
  // delete flight function
  var del_flight = function(fields){
    var $fields = $(fields),
        $block = $fields.closest('.form_block');
        
    $fields.find('.datepicker').datepicker('destroy');
    // $fields.find('.autocomplete').autocomplete('destroy'); // this line is a cause of freezing, maybe it's a bug in jquery-ui
    $fields.find('._destroy').val('1');
    $fields.addClass('destroyed').hide();

    var count = $block.find('.fields:not(.destroyed)').length;
    if (count < 2) {
      add_flight($block);
    }    
  };
  // click to delete flight
  $('#flights').on('click', 'a.delete', function(e) {
    e.preventDefault();
    var $t = $(this),
        $fields = $t.closest('.fields');

    var is_empty_fields = !$fields.find(':input[value!=""]').filter(':visible').length;
    if (is_empty_fields || confirm($t.data('check'))) {
      del_flight($fields);
    }
  });

  // add paymnet
  var add_payment = function(payment_block) {
    var $block = $(payment_block),
        $last_fields = $block.find('.fields:last'),
        num = $last_fields.length > 0 ? parseInt($last_fields.attr('id').replace(/payment_\w+_/, ''), 10) + 1 : 0,
        payment, html;

    if ($block.is('#payments_in')) {
      payment = {
        num: num,
        id: '',
        _destroy: '',
        date_in: '',
        amount: '0.0',
        description: '',
        form_options: $block.data('form_options'),
        approved: false
      };
      html = JST['claims/payment_in'].render(payment);
    } else {
      var $first_fields = $block.find('.fields:first')
        first_course = $first_fields.find('.course').val(),
        currency = $('#claim_operator_price_currency option:selected').html();
      payment = {
        num: num,
        id: '',
        _destroy: '',
        date_in: '',
        amount: '0.0',
        amount_width_class: $block.data('amount_width_class'),
        course: first_course,
        currency: currency,
        amount_prim: '0.0',
        form_options: $block.data('form_options'),
        approved: false
      };
      html = JST['claims/payment_out'].render(payment);
    }

    $block.find(' .add_row').before(html);
    var $fields = $block.find('.fields:last'),
        $approved = $fields.find('input.approved');
    if ($block.data('approved_disabled')) {
      $fields.find('input.approved').attr('readonly', true);
      $fields.find('.approved_label').addClass('disabled');
    }
    setDatepicker($fields, true);
    customizeSelect($fields, true);
  }
  $('#payments_in, #payments_out').on('click', 'a.add', function(e) {
    e.preventDefault();
    var $t = $(this);
    add_payment($t.closest('.form_block'));
    if ($(e.delegateTarget).is('#payments_in')) {
      calculate_tourist_debt();
    } else {
      calculate_operator_debt();
    }
  });

  // del payment
  var del_payment = function(fields) {
    var $fields = $(fields),
        $block = $fields.closest('.form_block');

    $fields.find('.ik_select select').ikSelect('detach');
    $fields.find('.datepicker').datepicker('destroy');
    $fields.find('._destroy').val('1');
    $fields.addClass('destroyed').hide();

    if ($block.find('.fields:not(.destroyed)').length === 0) {
      add_payment($block);
    }
  };
  $('#payments_in, #payments_out').on('click', 'a.delete', function(e) {
    e.preventDefault();
    var $t = $(this),
        $fields = $t.closest('.fields');
    if ($fields.hasClass('disabled') || !confirm($t.data('check'))) { return; }
    del_payment($fields);
    if ($(e.delegateTarget).is('#payments_in')) {
      calculate_tourist_debt();
    } else {
      calculate_operator_debt();
    }
  });

  setTitles();
  set_editable_bonus_percent();
  set_claims_sticky_header();
  set_claims_waypoint();
  save_tour_price();
  set_claims_tooltip(true);

  // After refresh claims container, addition to default after refresh
  $('body').on('refreshed', '.claims', function(e) {
    set_claims_sticky_header();
    set_claims_waypoint();
    set_claims_tooltip();
  });

});

// Tour duration
$(document).ready(function() {
	set_deys();
	$("input#claim_arrival_date").on('change', set_deys);
	$("input#claim_departure_date").on('change', set_deys);
});

function set_deys() {
	arrival_date = Globalize.parseDate($("input#claim_arrival_date").val());
	departure_date = Globalize.parseDate($("input#claim_departure_date").val());
	if (arrival_date != null && departure_date != null && arrival_date != "" && departure_date != "" && departure_date >= arrival_date) {
		deys =  departure_date - arrival_date;
		$("label#deys").text(deys/1000/60/60/24+1)
	}
};

// On ready
$(function() {
  // Row highlight
  $('body').on('click', '#claims td', function(e) {
    var $row = $(this).closest('.row'),
        $hrow = $('#claims .row.highlight');
    if ($row.get(0) == $hrow.get(0)) {
      $row.toggleClass('highlight');
    } else {
      $hrow.removeClass('highlight');
      $row.addClass('highlight');
    }
  });

  $('.edit_claim').on('change autocompleteselect', ':input', function() {
    if ($('.edit_claim').data('changed') != true && !$('.edit_claim').data('locked')) {
      $.ajax({
        url: $('.edit_claim').data('lockpath'),
        type: 'post',
        data: { _method: 'put' },
        success: function(data) {
          if (data.message) {
            setTimeout(function(){
              $('.edit_claim').data('changed', false);
            }, 174000);
            if ($('#content .top h1').text().indexOf(data.message) == -1) {
              $('#content .top h1').append(' ' + data.message);
            }
            $('.edit_claim').data('changed', true);
          } else if(data.locked) {
            $('.edit_claim').data('locked', data.locked);
          }
        }
      });
    }
  });
// Firefox bug click after beforeunload
  $('a.save').mouseup(function(){
    $('.edit_claim').data('changed', false)
  });

  $(window).bind('beforeunload', function() {
    if ($('.edit_claim').data('changed')) {
      return 'Внесены изменения, вы уверены, что хотите отказаться?';
    }
  });

  $(window).unload(function() {
    if ($('.edit_claim').data('changed')) {
      $.ajax({
        url: $('.edit_claim').data('unlockpath'),
        type: 'post',
        data: { _method: 'put' }
      });
    }
   });

  // Window scroll event
  $(window).scroll(function() {
    $(window).trigger('scroll.claims');
  });
});

//Tourist special_offer
$(function(){
  $('#special_offer_checkbox.active').bind('click', function() {
    var classList = $(this).attr('class').split(/\s+/);
    var data = $(this).attr("data");
    if ($(this).hasClass('active')) {
      if(!confirm(data)) {
        $(this).toggleClass('active');
        $('#' + $(this).attr('for')).attr('checked', $(this).hasClass('active')).trigger('change');
      }
    }
  });
});
