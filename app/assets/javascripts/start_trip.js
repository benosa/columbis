var step = $('html').data('start_trip_step');
var ratios = {
   1024: 0.7,
   1280: 0.75,
   1366: 0.8
}

function get_delta() {
  var width = $(window).width();
  var delta = 1;
  for (var value in ratios) {
    if (width <= value) {
      delta = ratios[value]
      break;
    }
  }

  return delta;
}


function step_cookie_set(step, path) {
  var currentDate = new Date();
  expirationDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()+3, 0, 0, 0);
  $.cookie('start_trip_step', step, {expires: expirationDate, path: path});
}

function getParameterByName(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
}

function set_scale(){
  $('.game_image').each(function( index ) {
    $this = $(this)
    $this.css({ width: $this.data('width') * get_delta(), height: $this.data('height') * get_delta()});
  });
}

function set_button_position(delta) {
  set_scale();
  offset = $('.logo').offset();
  $('#disable_game').offset({ top: offset.top + 40 * get_delta(), left: offset.left - 90 * get_delta()});
}

function step0_images_position(delta) {
  set_scale();
  offset = $('#user_session_submit').offset();
  $('#cat_step0').offset({ top: offset.top + 170, left: offset.left });
  $('#cloud1_step0').offset({ top: offset.top - 150, left: offset.left - 610});
}

function step1_images_position(delta) {
  set_scale();
  var offset = $('.save').offset();
  $('#glove_step1').offset({ top: offset.top -100, left: offset.left - 100 });
  offset = $('#company_name').offset();
  $('#cat_step1').offset({ top: offset.top, left: offset.left + 240 });
  offset = $('#company_full_name').offset();
  $('#cloud1_step1').offset({ top: offset.top, left: offset.left + 50 });
}

function step2_images_position(delta) {
  set_scale();
  var offset = $('#add_worker').offset();
  $('#cat_step2').offset({ top: offset.top - 300 * get_delta(), left: offset.left - 350 * get_delta() });
  var offset = $('#cat_step2').offset();
  $('#cloud1_step2').offset({ top: offset.top - 300 * get_delta(), left: offset.left - 250 * get_delta() });
 // $('#cat2').offset({ top: - 100, left: 100});
}

function step3_images_position(delta) {
  set_scale();
  var offset = $('.save').offset();
  $('#cat_step3').offset({ top: offset.top - 300 * get_delta(), left: offset.left - 350 * get_delta()});
  $('#cloud1_step3').offset({ top: offset.top - 800 * get_delta(), left: offset.left - 800 * get_delta()});
 // $('#cloud2_step3').offset({ top: offset.top - 450, left: offset.left - 500});
}

function step4_images_position(delta) {
  set_scale();
  var offset = $('.create_own').eq(4).offset();
  $('#cat_step4').offset({ top: offset.top - 195, left: offset.left - 360 });
  var offset = $('#cat_step4').offset();
  $('#cloud1_step4').offset({ top: offset.top + 55, left: offset.left - 760 });
}

function step5_images_position(delta) {
  set_scale();
  var offset = $('.new_claim_link').first().offset();
  $('#cat_step5').offset({ top: offset.top + 35, left: offset.left + 100 });
  $('#cloud1_step5').offset({ top: offset.top + 100, left: offset.left + 395 });
}

function step6_images_position(delta) {
  set_scale();
  var offset = $('#claim_applicant_attributes_address').offset();
  $('#cat_step6').offset({ top: offset.top + 35, left: offset.left - 195 });
  offset = $('#claim_applicant_attributes_address').offset();
  $('#cloud1_step6').offset({ top: offset.top + 5, left: offset.left + 120 });
  offset = $('#claim_arrival_date').offset();
  $('#glove_step6').offset({ top: offset.top + 20, left: offset.left - 110});
  offset = $('.tourist_stat').first().offset();
  $('#glove_step6_2').offset({ top: offset.top + 20, left: offset.left - 110});
  offset = $('.save').first().offset();
  $('#glove_step6_3').offset({ top: offset.top - 100, left: offset.left - 110});
}

// function step7_images_position(delta) {
//   var offset = $('.id_link').first().offset();
//   $('#cat_step7').offset({ top: offset.top + 2, left: offset.left + 17 });
// }

function step7_images_position(delta) {
  set_scale();
  var offset = $('#claim_country_name').first().offset();
  $('#cat_step7').offset({ top: offset.top - 278, left: offset.left - 355});
  $('#cloud1_step7').offset({ top: offset.top - 508, left: offset.left - 255});
  offset = $('.save_and_close').first().offset();
  $('#glove_step7').offset({ top: offset.top - 110, left: offset.left - 110});
}

function step8_images_position(delta) {
  set_scale();
  var offset = $('.new_claim_link').last().offset();
  $('#cat_step8').offset({ top: offset.top - 288, left: offset.left - 345});
  $('#cloud1_step8').offset({ top: offset.top - 338, left: offset.left - 995});
}

function step9_images_position(delta) {
  set_scale();
  var offset = $('#claim_applicant_attributes_address').offset();
  $('#cat_step9').offset({ top: offset.top + 35, left: offset.left - 195 });
  offset = $('#claim_applicant_attributes_address').offset();
  $('#cloud1_step9').offset({ top: offset.top + 25, left: offset.left + 150 });
  offset = $('#claim_arrival_date').offset();
  $('#glove_step9').offset({ top: offset.top + 20, left: offset.left - 110});
  offset = $('.tourist_stat').first().offset();
  $('#glove_step9_2').offset({ top: offset.top + 20, left: offset.left - 110});
  offset = $('.save_and_close').first().offset();
  $('#glove_step9_3').offset({ top: offset.top - 100, left: offset.left - 110});
}

function step12_images_position(delta) {
  set_scale();
  var offset = $('#check_date_link').offset();
  $('#glove1_step12').offset({ top: offset.top - 90, left: offset.left - 95});
  offset = $('#operator_maturity_link').offset();
  $('#glove2_step12').offset({ top: offset.top - 90, left: offset.left - 95});
  offset = $('#arrival_date_link').offset();
  $('#glove3_step12').offset({ top: offset.top - 90, left: offset.left - 95});
  offset = $('.pagination').offset();
  $('#cat_step12').offset({ top: offset.top - 325, left: offset.left + 220});
  $('#cloud1_step12').offset({ top: offset.top - 445, left: offset.left + 520});
}

function step13_images_position(delta) {
  set_scale();
  var offset = $('#add_potential').offset();
  $('#cat_step13').offset({ top: offset.top - 295, left: offset.left - 330});
  $('#cloud1_step13').offset({ top: offset.top - 535, left: offset.left - 750});
}

function step14_images_position(delta) {
  set_scale();
  var offset = $('#tourist_full_name').offset();
  $('#glove1_step14').offset({ top: offset.top + 45, left: offset.left + 320});
  // offset = $('#tourist_phone_number').offset();
  // $('#glove2').offset({ top: offset.top - 30, left: offset.left + 280});
  offset = $('.save_and_close').first().offset();
  $('#cat_step14').offset({ top: offset.top - 295, left: offset.left - 330});
  $('#cloud1_step14').offset({ top: offset.top - 625, left: offset.left - 540});
}

function add_image(id, name, delta, position, zindex) {
  var img = $('<img id="' + id + '" class="game_image">');
  img.attr('src', '/assets/start_trip/' + name);
  img.appendTo('html');
  img.css({position: position, zIndex: zindex});
  img.load(function() {
    img.data('width', img.width() * delta);
    img.data('height', img.height() * delta);
    if (delta * get_delta() != 1) {
      img.css({ width: img.data('width') * get_delta(), height: img.data('height') * get_delta()});
    }
  });

}

function block_a(attr, selector) {
  $("a").bind("click", function(event) {
    if (!$(event.target).hasClass('logout') &&
    ($(event.target).attr(attr) === undefined ||
    $(event.target).attr(attr) != undefined &&
    $(event.target).attr(attr).indexOf(selector) == -1)) {
      event.stopImmediatePropagation();
      event.preventDefault();
    }
  });
}

function resize_action(func, delta) {
  var resizeId;
    $(window).resize(function() {
      clearTimeout(resizeId);
      resizeId = setTimeout(func, 200, delta);
    });
}

function new_claim_scroll() {
  $( ".applicant input, #claim_arrival_date" ).change(function() {
    var all_set = true;
    $('.applicant .required, #claim_arrival_date, #claim_applicant_attributes_full_name').each(function() {
      if ($(this).attr('value') == "") {
        all_set = false
      }
    });

    if (all_set == true) {
      var offset = $('.tourist_stat-wrap').offset();
      $('html').scrollTop(offset.top);
    }

  });
}

$(function(){

  $("#game_enter_on").bind("click", function() {
    step_cookie_set(-3, '/');
    window.location.href = '/';
  });

  //var step = $('html').data('start_trip_step');
  cat_reg = getParameterByName('start_trip');
  if (cat_reg && !step) {
    add_image('cat_step0', 'cat_left.png', 1, 'absolute', 9999);
    add_image('cloud1_step0', 'enter.png', 1, 'absolute', 9999);
    step0_images_position(1);
    resize_action(step0_images_position, 1);
  }

  if (step > 0) {
    add_image('disable_game', 'disable-lg.png', 0.7, 'fixed', 9999);
    $('#disable_game').wrap('<a id="disable_game_link" href="#"></a>');
    set_button_position(1);
    resize_action(set_button_position, 1);
    $("#disable_game_link").bind("click", function() {
      step_cookie_set(-1, '/');
      window.location.href = '/';
    });
  }

  if (step == '1') {
    add_image('cat_step1', 'cat_left.png', 1, 'absolute', 9999)
    add_image('glove_step1', 'fingerRightDown.png', 1, 'fixed', 9999);
    add_image('cloud1_step1', 'game-1.png', 1, 'absolute', 9999);
    step1_images_position(1);
    resize_action(step1_images_position, 1);

    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '2') {
    add_image('cat_step2', 'cat_right.png', 1, 'fixed', 9999);
    add_image('cloud1_step2', 'game-2.png', 1, 'fixed', 9999);
    step2_images_position(1);
    resize_action(step2_images_position, 1);

    block_a('id', 'add_worker');
    $("#add_worker").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '3') {
    add_image('cat_step3', 'cat_right.png', 1, 'fixed', 9999);
    add_image('cloud1_step3', 'game-3.png', 0.8, 'fixed', 9999);
    step3_images_position(1);
    resize_action(step3_images_position, 1);

    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '4') {
    add_image('cat_step4', 'cat_right.png', 1, 'absolute', 9999);
    add_image('cloud1_step4', 'game-4.png', 1, 'absolute', 9999);
    step4_images_position(1);
    resize_action(step4_images_position, 1);
    block_a('class', 'create_own');
    $(".create_own").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '5') {
    add_image('cat_step5', 'cat_left.png', 1, 'absolute', 9999);
    add_image('cloud1_step5', 'game-5.png', 1, 'absolute', 9999);
    step5_images_position(1);
    resize_action(step5_images_position, 1);
    block_a('class', 'new_claim_link');
    $(".new_claim_link").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '6') {
    new_claim_scroll();
    $("body").on("column_resize", step6_images_position);
    add_image('cloud1_step6', 'game-6.png', 0.75, 'absolute', 98);
    add_image('cat_step6', 'cat_left.png', 1, 'absolute', 98);
    add_image('glove_step6', 'fingerRightTop.png', 1, 'absolute', 9999);
    add_image('glove_step6_2', 'fingerRightTop.png', 1, 'absolute', 9999);
    add_image('glove_step6_3', 'fingerRightDown.png', 1, 'fixed', 9999);
   // $('#glove_step6_3').css( {position: 'fixed'} );
    resize_action(step6_images_position, 1);
    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '7') {
    $("body").on("column_resize", step7_images_position);
    add_image('cat_step7', 'cat_right.png', 1, 'absolute', 98);
    add_image('glove_step7', 'fingerRightDown.png', 1, 'fixed', 9999);
    add_image('cloud1_step7', 'game-7.png', 0.8, 'absolute', 9999);
    resize_action(step7_images_position, 1);
    block_a('class', 'save');
    $(".save").bind("click", function(event) {
      if ($('#claim_country_name').attr('value') == '') {
        event.stopImmediatePropagation();
        event.preventDefault();
      } else {
        step_cookie_set(step, '/');
      }
    });
  }

  if (step == '8' || step == '10') {
    add_image('cat_step8', 'cat_right.png', 1, 'fixed', 999);
    if (step == '8') {
      add_image('cloud1_step8', 'game-7-1.png', 1, 'fixed', 999);
    } else {
      add_image('cloud1_step8', 'game-7-2.png', 1, 'fixed', 999);
    }
    step8_images_position(1);
    resize_action(step8_images_position, 1);
    block_a('class', "new_claim_link");
    $(".new_claim_link").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '9' || step == '11') {
    new_claim_scroll();
    $("body").on("column_resize", step9_images_position);
    add_image('cat_step9', 'cat_left.png', 1, 'absolute', 98);
    add_image('cloud1_step9', 'game-6.png', 0.75, 'absolute', 98);
    add_image('glove_step9', 'fingerRightTop.png', 1, 'absolute', 9999);
    add_image('glove_step9_2', 'fingerRightTop.png', 1, 'absolute', 9999);
    add_image('glove_step9_3', 'fingerRightDown.png', 1, 'fixed', 9999);
   // $('#glove_step6_3').css( {position: 'fixed'} );
    resize_action(step9_images_position, 1);
    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '12') {
    var clicks = {
      arrival_date: 0,
      check_date: 0,
      operator_maturity: 0
    }

    add_image('cat_step12', 'cat_left.png', 1, 'absolute', 9999);
    add_image('glove1_step12', 'fingerRightDown.png', 1, 'absolute', 9999);
    add_image('glove2_step12', 'fingerRightDown.png', 1, 'absolute', 9999);
    add_image('glove3_step12', 'fingerRightDown.png', 1, 'absolute', 9999);
    add_image('cloud1_step12', 'game-8.png', 1, 'absolute', 9999);

    step12_images_position();
    resize_action(step12_images_position, 1);


    $("a").bind("click", function(event) {
      if (!$(event.target).hasClass('logout') &&
        !$(event.target).parents('.claims_header').length == 1){
        event.stopImmediatePropagation();
        event.preventDefault();
      }
    });

    $(".claims_header a").live("click", function() {
      if (clicks[$(this).data('sort')] != undefined) {
        clicks[$(this).data('sort')] = 1;
      }

      var all = true;
      for (var prop in clicks) {
        if (clicks[prop] == 0) {
          all = false
        }
      }

      if (all) {
        step_cookie_set(step, '/')
        window.location.href = '/tourists?potential=true';
      }
    });

  }

  if (step == '13') {
    add_image('cat_step13', 'cat_right.png', 1, 'fixed', 9999);
    add_image('cloud1_step13', 'game-10.png', 0.75, 'fixed', 98);
    step13_images_position(1);
    resize_action(step13_images_position, 1);
    block_a('id', 'add_potential');
    $("#add_potential").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '14') {
    add_image('cat_step14', 'cat_right.png', 1, 'fixed', 9999);
    add_image('cloud1_step14', 'game-12.png', 0.75, 'fixed', 999);
    add_image('glove1_step14', 'fingerLeftTop.png', 1, 'absolute', 9999);
    step14_images_position(1);
    resize_action(step14_images_position, 1);
    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

});