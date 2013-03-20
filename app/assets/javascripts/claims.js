// search
function getCurrentParams(el){
  var currentParams = { sort:'reservation_date', direction:'desc', filter: '' },
      $current_sort = $('#claims th a.current'),
      $el = $(el),
      href;

  if ($el.is('#claims th a')) {
    href = $el.attr('href');
  } else {
    href = $current_sort.attr('href');
  }

  if (href) {
    var href = $el.attr('href');
    href = href.replace(/\/claims.*\?/, '');
    var params = href.split('&');
    for (var i = 0, len = params.length; i < len; i++){
      var pair = params[i].split('=');
      switch (pair[0]) {
        case 'sort':
          currentParams.sort = pair[1];
          break;
        case 'direction':
          if ($el[0] == $current_sort[0]) {  // change direction for current sort column
            currentParams.direction = (pair[1]=='asc' ? 'desc' : 'asc');
          } else {
            currentParams.direction = pair[1];
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
  currentParams.list_type = $('.accountant_login').attr('list_type');

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

      set_claims_waypoint();
      setTitles();
      set_editable_bonus_percent();
      remove_duplicated_totals();
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
  var options = {
    wrapper: null, //'<table class="sticky-wrapper" />',
    stuckClass: 'stuck',
    offset: function() { return -$(this).height(); }
  };

  var selector = '#claims .sticky-element',
      $tr = $(selector),
      w = $tr.width(),
      $table = $tr.closest('table'),
      $thead = $table.find('thead'),
      $tbody = $table.find('tbody');

  // Fix width for thead and tbody
  $tr.width(w);
  $table.width(w);
  $thead.width(w);
  $tbody.width(w);
  $tr.find('th').each(function() {
    $(this).width($(this).width());
  });
  $tbody.find('tr:first-child td').each(function() {
    $(this).width($(this).width());
  });

  set_sticky_elements(selector, options);
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

$(function(){
  var VISA_STATUSES = ['nothing_done', 'docs_got', 'docs_sent', 'visa_approved', 'all_done'];

  function trim(str) {
     return str.replace(/^\s+|\s+$/g, '');
  }

  // claims filter and totals filter
  // $('.filter_bar select, .filter_bar input').live('change', function(){
  //   setFilters(this);
  // });

  // // totals filter
  // $('#total_years').live('change', function(){
  //   setFilters(this);
  // });

  // redefine default submition of filter form
  // $('#filter_bar').submit(function(event) {
  //   event.preventDefault();
  //   loadList(getCurrentSortParams());
  //   return false;
  // });

  // change claims per page
  // $('.claims #per_page').live('change', function() {
  //   var link = $('option:selected', this).data('link')
  //   loadList(null, link);
  // });

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
    var status = $(this).val();
    $('#claim_visa').val(status);
    $('#claim_visa_check').removeClass(VISA_STATUSES.join(' ')).addClass(status);
  });

  $('#claim_visa_confirmation_flag').change(function(e){
    var val = $('#claim_visa').val(),
        initial_status = VISA_STATUSES[0],
        done_status = VISA_STATUSES[VISA_STATUSES.length - 1];
    $('#claim_visa_check').removeClass(val);
    if (this.checked) {
      $('#claim_visa_check').removeClass(done_status).addClass(initial_status).datepicker('enable');
      $('#claim_visa').val(initial_status);
      $('#claim_visa_status').ikSelect('enable').ikSelect('select', initial_status);
    } else {
      $('#claim_visa_check').removeClass(VISA_STATUSES.join(' ')).addClass(done_status).val('').datepicker('disable');
      $('#claim_visa').val(done_status);
      $('#claim_visa_status').ikSelect('disable').ikSelect('select', initial_status);
    }
  });

  // set initial state for visa fields
  $('#claim_visa_confirmation_flag').triggerHandler('change');

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

  // quick search
  // $('#filter_bar #filter').keyup(function(){
  //   var self = this
  //   exclusive_delay(function(){
  //     loadList(getCurrentSortParams(self));
  //   }, 300 );
  // });

  // sort
  // $('#claims th a').live('click', function(e){
  //   e.preventDefault();
  //   if (Tourism.online) {
  //     loadList(getCurrentParams(this));
  //   } else {
  //     var href = $(this).attr('href');
  //     location.href = href.replace(/\/claims.*\?/, '/claims/search?');
  //   }
  // });

  // pagination
  // $(".claims .pagination a").each(function(i){
  //   var href = $(this).attr('href');
  //   $(this).attr('href', href.replace(/\/claims.*\?/, '/claims/search?'));
  // });

  // $('.claims .pagination a').live('click', function(e) {
  //   e.preventDefault();
  //   loadList(null, $(e.currentTarget).attr('href'));
  // });

  //  operator_price_currency change
  $('#claim_operator_price_currency').change(function(){
    var currency = $('option:selected', this).html();
    $('#payments_out .new_record .operator_currency, #payments_out .operator_debt_currency').html(currency);
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
  function course(elem) {
    switch (elem.val())
    {
      case 'eur':
        return parseFloat($('#claim_course_eur').val());
      case 'usd':
        return parseFloat($('#claim_course_usd').val());
      default:
        return 1;
    }
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

    var sum_price = parseFloat($('#claim_tour_price').val()) * course($('#claim_tour_price_currency'));
    sum_price = sum_price +
      parseFloat($('#claim_additional_services_price').val()) * course($('#claim_additional_services_price_currency'));

    // some fields are calculated per person
    fields =  ['#claim_visa_price', '#claim_children_visa_price', '#claim_insurance_price', '#claim_additional_insurance_price', '#claim_fuel_tax_price'];


    var total = 0;
    for(var i=0; i<fields.length; i++)  {
      var basis = fields[i].replace(/_price$/, '');
      var count = parseFloat($(basis + '_count').val());
      if (isFinite(count) && count > 0) {
        total = total + parseFloat($(fields[i]).val()) * count * course($(fields[i] +'_currency'));
      }
    }
    sum_price = Math.round(sum_price + total);

    return sum_price;
  };

  function adjust_calculation() {
    var total = calculate_tour_price();
    $('#claim_primary_currency_price').val(total);
    $('#claim_primary_currency_price').change();
    calculate_tourist_debt();
    update_calculation();
  };

  $('#claim_course_eur, #claim_course_usd, tr.countable input').bind('keyup, input', function(){
    adjust_calculation();
  });

  $('tr.countable select').change(function(){
    adjust_calculation();
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
  var calculate_tourist_debt = function(event){
    var price = parseFloat($('#claim_primary_currency_price').val() || 0);
    var paid = 0.0;
    if (isFinite(price)) {
      $('#payments_in .fields').each(function (i) {
        var val = parseFloat($('#claim_payments_in_attributes_' + i + '_amount').val());
        if (isFinite(val)) {
          paid += val;
        }
      });
    }
    $('#claim_tourist_debt').val(price - paid);
  };

  var calculate_operator_debt = function(event){
    var price = parseFloat($('#claim_operator_price').val());
    var paid = 0.0;
    if (isFinite(price)) {
      $('#payments_out .fields').each(function (i) {
        var val = parseFloat($('#claim_payments_out_attributes_' + i + '_amount_prim').val());
        if (isFinite(val)) {
          paid += val;
        }
      });
    }
    $('#claim_operator_debt').val((price - paid).toFixed(2));
  };

  // $('#claim_operator_price').change(calculate_operator_debt);
  $('#claim_operator_price').on('keyup', calculate_operator_debt);

  var calculate_amount_prim = function(event){
    var $tr = $(event.currentTarget).closest('.fields'),
        course = $tr.find('input.course').val();
    if ($tr.find('input.course').length > 0){
      if (isFinite(course) && course > 0 ) {
        course = 1 / course;
      } else {
        course = 0;
      }
    }

    var amount = $tr.find('input.amount').val();
    var amount_prim = (course * amount).toFixed(2);
    $tr.find('input.amount_prim').val(amount_prim);
  };

  var reversive_calculate_amount = function(event){
    var $tr = $(event.currentTarget).closest('.fields'),
        course = $tr.find('input.course').val();
    if ($tr.find('input.course').length > 0){
      if (isFinite(course) && course > 0 ) {
        course = 1 / course;
      } else {
        course = 0;
      }
    }

    var amount_prim = $tr.find('input.amount_prim').val();

    if(course > 0) {
      var amount = (amount_prim / course).toFixed(2);
      $tr.find('input.amount').val(amount);
    } else {
      $tr.find('input.amount').val('0.00');
    }
  };

  $('#payments_in').on('keyup', 'input.amount', function(event){
    get_amount_in_word(event);
  	calculate_tourist_debt(event);
  });

  $('#payments_out').on('keyup', 'input.amount, input.course, input.reversed_course', function(event){
    calculate_amount_prim(event);
  	// get_amount_in_word(event);
  	calculate_operator_debt(event);
  });

	$('#payments_out').on('keyup', 'input.amount_prim', function(event){
    reversive_calculate_amount(event);
  	calculate_operator_debt(event);
  });

  $('#claim_primary_currency_price').change(get_amount_in_word);

  // autocomplete
  var $autocomplete = {
    touristLastName: {
      source: "/claims/autocomplete_tourist_last_name",
      select: function(event, ui) {
        var tr = $(this).closest('.fake_row');
        tr.find("input.passport_series").val(ui.item.passport_series);
        tr.find("input.passport_number").val(ui.item.passport_number);
        tr.find("input.date_of_birth").val(ui.item.date_of_birth);
        tr.find("input.passport_valid_until").val(ui.item.passport_valid_until);
        if(tr.hasClass('applicant')) {
          tr.find("input.phone_number").val(ui.item.phone_number);
          tr.find("input.address").val(ui.item.address);
          $('#claim_applicant_id').val(ui.item.id);
        } else {
          tr.next(".hidden_id").val(ui.item.id);
        }
      },
      minLength: 0
    },
    country: {
      source: "/claims/autocomplete_country",
      select: function(event, ui) {
        var $resort = $("input.autocomplete.resort");
        if ($(this).data('val') != ui.item.value)
          $resort.val('');
        $resort.autocomplete('option', 'source', '/claims/autocomplete_resort/' + ui.item.id);
      },
      change: function(eventn, ui) {
        $(this).data('val', this.value);
        $("input.autocomplete.resort").val('').autocomplete('option', 'source', '/claims/autocomplete_resort/' + this.value);
      },
      minLength: 0
    }
  };
  $("input.autocomplete.full_name").autocomplete($autocomplete.touristLastName);
  $("input.autocomplete.country").autocomplete($autocomplete.country);
  $("input.autocomplete.resort").autocomplete({
    source: "/claims/autocomplete_resort/" + $('#claim_country_name').data('id'),
    minLength: 0
  });

  // add tourist
	var add_tourist = function(e){
    e.preventDefault();

    var $common_fields = $('#tourists .applicant .common_fields');
    $('#tourists .add_row').before($('<div class="fake_row dependent"></div>'));
    var $new_dependent = $('#tourists .dependent:last');
    $new_dependent.append($common_fields.html());
    $new_dependent.after('<input type="hidden" class="hidden_id">');
    $new_dependent.find('input').each(function(n){
      $(this).removeClass('hasDatepicker');
      $(this).next('img').remove();
      $(this).val('');
      $(this).attr('value', '');
    });
    $new_dependent.attr('id', '');
    if (!$new_dependent.find('.delete').length)
      $new_dependent.append($('#tourists .applicant .delete').clone());

    var last_ind = 0;
    $('#tourists .dependent').each(function(i){
      $(this).attr('id','dependent' + (i+2));

      $(this).find('a.delete').click(del_tourist);
      $(this).find('a.delete').attr('id','del'+(i+2));

      $(this).find('.num').text(i+2);

      $(this).find('input.autocomplete.full_name').autocomplete($autocomplete.touristLastName);
      $(this).find('input.autocomplete.full_name').attr('id', 'claim_dependents_attributes_' + i + '_full_name');
      $(this).find('input.autocomplete.full_name').attr('name', 'claim[dependents_attributes][' + i + '][full_name]');

      $(this).find('input.date_of_birth').attr('id', 'claim_dependents_attributes_' + i + '_date_of_birth');
      $(this).find('input.date_of_birth').attr('name', 'claim[dependents_attributes][' + i + '][date_of_birth]');

      $(this).find('input.passport_series').attr('id', 'claim_dependents_attributes_' + i + '_passport_series');
      $(this).find('input.passport_series').attr('name', 'claim[dependents_attributes][' + i + '][passport_series]');

      $(this).find('input.passport_number').attr('id', 'claim_dependents_attributes_' + i + '_passport_number');
      $(this).find('input.passport_number').attr('name', 'claim[dependents_attributes][' + i + '][passport_number]');

      $(this).find('input.passport_valid_until').attr('id', 'claim_dependents_attributes_' + i + '_passport_valid_until');
      $(this).find('input.passport_valid_until').attr('name', 'claim[dependents_attributes][' + i + '][passport_valid_until]');

      setDatepicker(this, true);

      var hidden_id = $(this).next('[type=hidden]');
      hidden_id.attr('id', 'claim_dependents_attributes_' + i + '_id');
      hidden_id.attr('name', 'claim[dependents_attributes][' + i + '][id]');
      last_ind = i+1;
    });
	};
	$('#tourists a.add').click(add_tourist);

  // del tourist
  var del_tourist = function(e){
    e.preventDefault();

    var id = $(this).attr('id').replace(/del/,'');
    var $tr = $('#dependent' + id);
    if (id == 1)
      $('.applicant').closest('.fake_row').find(':input').val('');
    else {
      $tr.next('input[type=hidden]').remove();
      $tr.remove();
    }

    $('#tourists .dependent').each(function(i){
      $(this).find('.num').text(i+2)
    });
  };
	$('#tourists a.delete').click(del_tourist);

  // add payment
	var add_payment = function(e){
    e.preventDefault();

    var t_id = '#' + $(this).closest('.form_block').attr('id');
    $(t_id + ' .add_row').before($(t_id + ' .fields:first').clone(true, true).addClass('new_record'));
    // $(t_id + ' .fields:last').after('<input type="hidden" class="hidden_id">');
    $(t_id + ' .fields:last input.datepicker').removeClass('hasDatepicker');
    $(t_id + ' .fields:last input.datepicker').next('img').remove();
    $(t_id + ' .fields:last label.checkbox').removeClass('active');;

    var p_type = t_id.replace(/#payments_/,'');

    $(t_id + ' .fields:last').find('input').each(function(n){
      if($(this).hasClass('amount') || $(this).hasClass('amount_prim') || $(this).hasClass('course')) {
        if ($(this).hasClass('course')) return; // Leave last course
        $(this).val('0.00');
        $(this).attr('value', '0.00');
      } else if ($(this).hasClass('approved')) {
        this.checked = false;
      } else {
        $(this).val('');
      }
    });

    $(t_id + ' .fields').each(function(i){

      $(this).attr('id', (t_id.replace(/#payments/,'payment')) + '_' + i);

      $(this).find('a.delete').click(del_payment);
      $(this).find('a.delete').attr('id','del' + i);

      var $approved = $(this).find('input.approved[type=checkbox]');
      $approved.attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_approved');
      $approved.attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][approved]');
      $approved.removeAttr('checked');
      // $approved.prev('input[type=hidden]').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][approved]');

      var $approved_label = $(this).find('label.checkbox');
      $approved_label.attr('for', 'claim_payments_' + p_type + '_attributes_' + i + '_approved');

      $(this).find('input.date_in').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_date_in');
      $(this).find('input.date_in').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][date_in]');
      // $(this).find('input.datepicker').datepicker({ dateFormat: 'dd.mm.yy' });
      setDatepicker(this, true);

      $(this).find('input.amount').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_amount');
      $(this).find('input.amount').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][amount]');

      $(this).find('input.course').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_course');
      $(this).find('input.course').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][course]');

      $(this).find('input.amount_prim').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_amount_prim');
      $(this).find('input.amount_prim').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][amount_prim]');

      $(this).find('select.currency').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_currency');
      $(this).find('select.currency').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][currency]');


      $(this).find('input.description').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_description');
      $(this).find('input.description').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][description]');

      $(this).find('select.payment_form').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_form');
      $(this).find('select.payment_form').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][form]');

      // if using clone(true, true) for .fields block, it copies all events of element and its children
     //  $('#payments_in input.amount').unbind('change.tourism').bind('change.tourism', function(event){
     //    get_amount_in_word(event);
     //  	calculate_tourist_debt(event);
     //  });

	    // $('#payments_out input.amount, #payments_out input.course, #payments_out input.reversed_course')
     //  .unbind('change.tourism').bind('change.tourism', function(event){
     //    calculate_amount_prim(event);
     //  	// get_amount_in_word(event);
     //  	calculate_operator_debt(event);
     //  });

	    // $('#payments_out input.amount_prim').unbind('change.tourism').bind('change.tourism', function(event){
     //    reversive_calculate_amount(event);
     //  	calculate_operator_debt(event);
     //  });

      var hidden_id = $('input[type=hidden]', this);
      hidden_id.attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_id');
      hidden_id.attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][id]');
    });
	};
	$('#payments_in a.add').live('click', add_payment);
	$('#payments_out a.add').live('click', add_payment);

  // del payment
  var del_payment = function(e){
    e.preventDefault();
    var t_id = '#' + $(e.currentTarget).parent().parent().parent().parent().attr('id');
    var id = $(this).attr('id').replace(/del/,'');
    var $tr = $(t_id.replace(/payments/,'payment') + '_' + id);

    if (id === 0) {
      $tr.find('input').each(function(){
        if ($(this).hasClass('approved')) {
          this.checked = false;
        } else {
          $(this).val($(this).hasClass('amount') ? '' : '');
        }
      });
      $tr.next().removeAttr('value');
    } else {
      $tr.next('input[type=hidden]').remove();
      $tr.remove();
    }

    calculate_tourist_debt();
    calculate_operator_debt();
  };
	$('#payments_in a.delete').click(del_payment);
	$('#payments_out a.delete').click(del_payment);

  setTitles();
  set_editable_bonus_percent();
  set_claims_sticky_header();
  set_claims_waypoint();

});
