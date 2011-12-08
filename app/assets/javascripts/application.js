// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

$(function(){
  $('input.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });
  $('input.datetimepicker').datetimepicker({ dateFormat: 'yy-mm-dd', timeFormat: 'h:m' });

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
    if ($('#claim_calculation').val() == '' || /\[\a\]/.test($('#claim_calculation').val())) {
      var str = '';
      var val = parseFloat($('#claim_primary_currency_price').val());
      if (isFinite(val)) {
        str = str + val + 'rur = ';

        val = parseFloat($('#claim_tour_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_tour_price_currency').val() + ' + ';
        }

        if ($('#claim_visa_count').val() > 0){
          val = parseFloat($('#claim_visa_price').val());
          if (isFinite(val) && val > 0) {
            str = str + $('#claim_visa_count').val() + 'x' + val + $('#claim_visa_price_currency').val() + ' + ';
          }
        }

        val = parseFloat($('#claim_insurance_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_insurance_price_currency').val() + ' + ';
        }

        val = parseFloat($('#claim_additional_insurance_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_additional_insurance_price_currency').val() + ' + ';
        }
        val = parseFloat($('#claim_fuel_tax_price').val());
        if (isFinite(val) && val > 0) {
          str = str + val + $('#claim_fuel_tax_price_currency').val() + ' + ';
        }

        if (str != '') {
          $('#claim_calculation').val(str.slice(0, -2) + ' [a]');
        }
      }

    }
  }

  var calculate_tour_price = function(){
    var visa_price = parseFloat($('#claim_visa_price').val()) *
      parseFloat($('#claim_visa_count').val()) * course($('#claim_visa_price_currency'));

    var fee = parseFloat($('#claim_tour_price').val()) * course($('#claim_tour_price_currency')) +
      parseFloat($('#claim_insurance_price').val()) * course($('#claim_insurance_price_currency')) +
      parseFloat($('#claim_additional_insurance_price').val()) * course($('#claim_additional_insurance_price_currency')) +
      parseFloat($('#claim_fuel_tax_price').val()) * course($('#claim_fuel_tax_price_currency'));

    return fee + visa_price;
  }

  $('tr.countable input, tr.countable select').change(function(){
    var total = calculate_tour_price();
    $('#claim_primary_currency_price').val(total);
    $('#claim_primary_currency_price').change();
    update_calculation();
  });

  // get system course
  var get_system_course = function(e){
    e.preventDefault();
    $.ajax({
      url: "/get_currency_course",
      type: "POST",
      data: "currency=" + $(e.currentTarget).prev('input').attr('id').replace(/claim_course_/,''),
      cache: false,
      success: function(resp){
        $(e.currentTarget).prev('input').val(resp);
        calculate_tour_price();
      }
    });
  }
	$('#courses_block a').click(get_system_course);

  // city, resort, flights
  $('#claim_city').change(function(){
    if($('#claim_airport_to').val() == '') {
      $('#claim_airport_to').val($('#claim_city').val());
    }
  });

  $('#claim_resort').change(function(){
    if($('#claim_airport_back').val() == '') {
      $('#claim_airport_back').val($('#claim_resort').val());
    }
  });

  // green lamp
  $('#claim_early_reservation').change(function(){
    if (this.checked) {
      $('.lamp_block').css('background-position','top left');
    } else {
      $('.lamp_block').css('background-position','0% -36px')
    }
  });

  // user color
  $('#user_color').live('change', function(event){
    $('.color_sample').css('background-color', $(event.currentTarget).val());
  });
  $('.color_sample').css('background-color', $('#user_color').val());

  // amount in word
	function create_data_string($elem){
	  var amount = 0, currency = '';
	  if(/^claim_payments_.{2,3}_attributes_\d+_(amount|currency)/.test($elem.attr('id'))){
	    // trying to find curr in row
      amount = $elem.closest('tr').find('input.amount').val();
      currency = $elem.closest('tr').find('select.currency').val();
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
      data: create_data_string($(this)),
      cache: false,
      success: function(resp){
        if(/^claim_payments_.{2,3}_attributes_\d+_(amount|currency)/.test($(event.currentTarget).attr('id'))){
          $(event.currentTarget).closest('tr').find('.description').val(resp);
        }
        else {
          $('#price_as_string').val(resp);
        }
      }
    });
	}
	$('#payments_in .amount').change(get_amount_in_word);
  $('#payments_out .amount').change(get_amount_in_word);

  $('#payments_in .currency').change(get_amount_in_word);
  $('#payments_out .currency').change(get_amount_in_word);

  $('#claim_primary_currency_price').change(get_amount_in_word);

  // visa_check
  $('#claim_visa_check').click(function(){
    var statuses = ['nothing_done', 'docs_got', 'docs_sent', 'visa_approved', 'passport_received'];
    var curr = statuses.indexOf($('#claim_visa').val());
    var next = curr + 1;
    if (statuses[curr] == 'passport_received') {
      next = 0;
    }

    $('#claim_visa_check').removeClass(statuses[curr]);
    $('#claim_visa_check').addClass(statuses[next]);
    $('#claim_visa').val(statuses[next]);
  });

  // autocomplete
  var $autocomplete = {
    touristLastName: {
      source: "/claims/autocomplete_tourist_last_name",
      select: function(event, ui) {
        var tr = $(event.target).parent().parent();
        tr.find("input.passport_series").val(ui.item.passport_series);
        tr.find("input.passport_number").val(ui.item.passport_number);
        tr.find("input.date_of_birth").val(ui.item.date_of_birth);
        tr.find("input.passport_valid_until").val(ui.item.passport_valid_until);
        if(tr.hasClass('applicant')) {
          tr = tr.next();
          tr.find("input.phone_number").val(ui.item.phone_number);
          tr.find("input.address").val(ui.item.address);
          $('#claim_applicant_id').val(ui.item.id);
        } else {
          tr.next(".hidden_id").val(ui.item.id);
        }
      }
    },
      paymentOutForm: {
      source: "/claims/autocomplete_common/form"
    },
      meals: {
      source: "/claims/autocomplete_common/meals"
    },
      placement: {
      source: "/claims/autocomplete_common/placement"
    },
      hotel: {
      source: "/claims/autocomplete_common/hotel"
    },
      airline: {
      source: "/claims/autocomplete_model_common/airline"
    },
      operator: {
      source: "/claims/autocomplete_model_common/operator"
    },
      country: {
      source: "/claims/autocomplete_model_common/country",
      select: function(event, ui) {
        $("input.autocomplete.resort").autocomplete($autocomplete.resort);
      }
    },
      city: {
      source: "/claims/autocomplete_model_common/city",
      select: function(event, ui) {
        if($('#claim_airport_to').val() == '') {
          $('#claim_airport_to').val(ui.item.value);
        }
      }
    },
      resort: {
      source: "/claims/autocomplete_model_common/resort",
      select: function(event, ui) {
        if($('#claim_airport_back').val() == '') {
          $('#claim_airport_back').val(ui.item.value);
        }
      }
    },
      airport: {
      source: "/claims/autocomplete_common/airport",
      select: function(event, ui) {
        $(event.target).attr('value', ui.item.value);
      }
    }
  };
  $("input.autocomplete.full_name").autocomplete($autocomplete.touristLastName);
  $("input.autocomplete.payment_form").autocomplete($autocomplete.paymentOutForm);
  $("input.autocomplete.meals").autocomplete($autocomplete.meals);
  $("input.autocomplete.placement").autocomplete($autocomplete.placement);
  $("input.autocomplete.hotel").autocomplete($autocomplete.hotel);
  $("input.autocomplete.airline").autocomplete($autocomplete.airline);
  $("input.autocomplete.operator").autocomplete($autocomplete.operator);
  $("input.autocomplete.country").autocomplete($autocomplete.country);
  $("input.autocomplete.city").autocomplete($autocomplete.city);
  $("input.autocomplete.resort").autocomplete($autocomplete.resort);
  $("input.autocomplete.airport").autocomplete($autocomplete.airport);

  $('input.autocomplete.country').change(function() {
    $autocomplete.city.source = "/claims/autocomplete_city/" + $("input.autocomplete.country").val();
  });

  // add tourist
	var add_tourist = function(e){
    e.preventDefault();

    $('#tourists .footer').before($('#tourists .applicant').clone());
    $('#tourists .applicant:last').after('<input type="hidden" class="hidden_id">');
    $('#tourists .applicant:last input').each(function(n){
      $(this).removeClass('hasDatepicker');
      $(this).next('img').remove();
      $(this).val('');
    });
    $('#tourists .applicant:last').attr('id', '').addClass('dependent').removeClass('applicant');

    var last_ind = 0;
    $('#tourists tr.dependent').each(function(i){
      $(this).attr('id','dependent' + (i+2));

      $(this).find('a.del').click(del_tourist);
      $(this).find('a.del').attr('id','del'+(i+2));

      $(this).find('.num').text(i+2)

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

      $(this).find('input.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });

      var hidden_id = $(this).next('[type=hidden]');
      hidden_id.attr('id', 'claim_dependents_attributes_' + i + '_id');
      hidden_id.attr('name', 'claim[dependents_attributes][' + i + '][id]');
      last_ind = i+1;
    });
	}
	$('#tourists a.add').click(add_tourist);

  // del tourist
  var del_tourist = function(e){
    e.preventDefault();

    var id = $(this).attr('id').replace(/del/,'');
    var $tr = $('#dependent' + id);
    if (id == 1) {
      $('.applicant input').val('');
      $('.applicant').next().find('input').val('');
      $('#claim_applicant_id').removeAttr('value');
    } else {
      $tr.next('input[type=hidden]').remove();
      $tr.remove();
    }

    $('#tourists tr.dependent').each(function(i){
      $(this).find('.num').text(i+2)
    });
  }
	$('#tourists a.del').click(del_tourist);

  // add payment
	var add_payment = function(e){
    e.preventDefault();

    var t_id = '#' + $(e.currentTarget).parent().parent().parent().parent().attr('id');
    $(t_id + ' .footer').before($(t_id + ' .fields:first').clone());
    $(t_id + ' .fields:last').after('<input type="hidden" class="hidden_id">');
    $(t_id + ' .fields:last input.datepicker').removeClass('hasDatepicker');
    $(t_id + ' .fields:last input.datepicker').next('img').remove();

    var p_type = t_id.replace(/#payments_/,'');

    $(t_id + ' .fields:last').find('input').each(function(n){
      if($(this).hasClass('amount')) {
        $(this).val('0.0');
      } else {
        $(this).val('');
      }
    });

    $(t_id + ' .fields').each(function(i){

      $(this).attr('id', (t_id.replace(/#payments/,'payment')) + '_' + i);

      $(this).find('a.del').click(del_payment);
      $(this).find('a.del').attr('id','del' + i);

      $(this).find('input.date_in').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_date_in');
      $(this).find('input.date_in').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][date_in]');
      $(this).find('input.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });

      $(this).find('input.amount').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_amount');
      $(this).find('input.amount').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][amount]');
      $(t_id + ' .amount').change(get_amount_in_word);

      $(this).find('select.currency').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_currency');
      $(this).find('select.currency').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][currency]');
      $(t_id + ' .currency').change(get_amount_in_word);

      $(this).find('input.description').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_description');
      $(this).find('input.description').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][description]');

      $(this).find('input.payment_form').attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_form');
      $(this).find('input.payment_form').attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][form]');
      $("input.autocomplete.payment_form").autocomplete($autocomplete.paymentOutForm);

      var hidden_id = $(this).next('[type=hidden]');
      hidden_id.attr('id', 'claim_payments_' + p_type + '_attributes_' + i + '_id');
      hidden_id.attr('name', 'claim[payments_' + p_type + '_attributes][' + i + '][id]');
    });
	}
	$('#payments_in a.add').live('click', add_payment);
	$('#payments_out a.add').live('click', add_payment);

  // del payment
  var del_payment = function(e){
    e.preventDefault();
    var t_id = '#' + $(e.currentTarget).parent().parent().parent().parent().attr('id');
    var id = $(this).attr('id').replace(/del/,'');
    var $tr = $(t_id.replace(/payments/,'payment') + '_' + id);

    if (id == 0) {
      $tr.find('input').each(function(){
        $(this).val($(this).hasClass('amount') ? '0.0' : '');
      });
      $tr.next().removeAttr('value');
    } else {
      $tr.next('input[type=hidden]').remove();
      $tr.remove();
    }

  }
	$('#payments_in a.del').click(del_payment);
	$('#payments_out a.del').click(del_payment);
});
