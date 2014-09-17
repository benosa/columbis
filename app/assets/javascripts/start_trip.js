var step = $('html').data('start_trip_step');

function step_cookie_set(step, path) {
  var currentDate = new Date();
  expirationDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()+3, 0, 0, 0);
  $.cookie('start_trip_step', step, {expires: expirationDate, path: path});
}

function getParameterByName(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
}

function step0_images_position() {
  offset = $('#user_session_submit').offset();
  $('#cat_1').offset({ top: offset.top + 170, left: offset.left });
  $('#cloud1_step0').offset({ top: offset.top - 150, left: offset.left + 210});
}

function step1_images_position() {
  var offset = $('.save').offset();
  $('#glove_step1').offset({ top: offset.top, left: offset.left - 100});
  offset = $('#company_name').offset();
  $('#cat_1').offset({ top: offset.top, left: offset.left + 140 });
  $('#cloud1_step1').offset({ top: offset.top -50, left: offset.left + 310});
  $('#cloud2_step1').offset({ top: offset.top, left: offset.left + 800});
}

function step2_images_position() {
  var offset = $('#add_worker').offset();
  $('#cat_2').offset({ top: offset.top - 250, left: offset.left - 200});
 // $('#cat2').offset({ top: - 100, left: 100});
}

function step3_images_position() {
  var offset = $('.save').offset();
  $('#cat_2').offset({ top: offset.top - 250, left: offset.left - 200});
  $('#cloud1_step3').offset({ top: offset.top - 700, left: offset.left - 500});
  $('#cloud2_step3').offset({ top: offset.top - 450, left: offset.left - 500});
}

function step4_images_position() {
  var offset = $('.create_own').first().offset();
  $('#cat_2').offset({ top: offset.top - 195, left: offset.left - 235 });
}

function step5_images_position() {
  var offset = $('.new_claim_link').first().offset();
  $('#cat_1').offset({ top: offset.top + 5, left: offset.left + 95 });
}

function step6_images_position() {
  var offset = $('#claim_applicant_attributes_address').offset();
  $('#cat_1').offset({ top: offset.top + 25, left: offset.left + 95 });
  var offset = $('#claim_arrival_date').offset();
  $('#glove_step6').offset({ top: offset.top + 20, left: offset.left - 110});
  var offset = $('.tourist_stat').first().offset();
  $('#glove_step6_2').offset({ top: offset.top + 20, left: offset.left - 110});
  var offset = $('.save_and_close').first().offset();
  $('#glove_step6_3').offset({ top: offset.top + 10, left: offset.left - 110});

}

function step7_images_position() {
  var offset = $('.id_link').first().offset();
  $('#cat_1').offset({ top: offset.top - 52, left: offset.left + 17 });
}

function step8_images_position() {
  var offset = $('#claim_country_name').first().offset();
  $('#cat_2').offset({ top: offset.top - 178, left: offset.left - 245});
  var offset = $('.save_and_close').first().offset();
  $('#glove_step8').offset({ top: offset.top + 10, left: offset.left - 110});
}

function step9_images_position() {
  var offset = $('.new_claim_link').last().offset();
  $('#cat_2').offset({ top: offset.top - 188, left: offset.left - 245});
}

function add_image(id, name) {
  var img = $('<img id="' + id + '">');
  img.attr('src', '/assets/start_trip/' + name);
  img.appendTo('html');
}

function block_a(attr, selector) {
  $("a").bind("click", function(event) {
    if ($(event.target).attr(attr) === undefined ||
    $(event.target).attr(attr) != undefined &&
    $(event.target).attr(attr).indexOf(selector) == -1) {
      event.stopImmediatePropagation();
      event.preventDefault();
    }
  });
}

function resize_action(func) {
  var resizeId;
    $(window).resize(function() {
      clearTimeout(resizeId);
      resizeId = setTimeout(func, 200);
    });
}

$(function(){
  //var step = $('html').data('start_trip_step');
  cat_reg = getParameterByName('start_trip');
  if (cat_reg && !step) {
    $('html').append('<div id="cat_1"></div>');
    add_image('cloud1_step0', 'columbis-1.png');
    step0_images_position();
    resize_action(step0_images_position);
  }

  if (step == '1') {
    $('html').append('<div id="cat_1"></div>');
    add_image('glove_step1', 'glove.png');
    $('#glove_step1').css({position: 'fixed'});
    add_image('cloud1_step1', 'columbis-31.png');
    add_image('cloud2_step1', 'columbis-32.png');
    step1_images_position();
    resize_action(step1_images_position);

    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '2') {
    $('html').append('<div id="cat_2"></div>');
    $('#cat_2').css({position: 'fixed'});
    step2_images_position();
    resize_action(step2_images_position);

    block_a('id', 'add_worker');
    $("#add_worker").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '3') {
    $('html').append('<div id="cat_2"></div>');
    $('#cat_2').css( {position: 'fixed'} );
    add_image('cloud1_step3', 'columbis-41.png');
    $('#cloud1_step3').css({position: 'fixed', width: '400px', height: '250px'});
    add_image('cloud2_step3', 'columbis-42.png');
    $('#cloud2_step3').css({position: 'fixed', width: '400px', height: '250px'});
    step3_images_position();
    resize_action(step3_images_position);

    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '4') {
    $('html').append('<div id="cat_2"></div>');
    step4_images_position();
    resize_action(step4_images_position);
    block_a('class', 'create_own');
    $(".create_own").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '5') {
    $('html').append('<div id="cat_1"></div>');
    step5_images_position();
    resize_action(step5_images_position);
    block_a('class', 'new_claim_link');
    $(".new_claim_link").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '6') {
    $("body").on("column_resize", step6_images_position);
    $('html').append('<div id="cat_1"></div>');
    add_image('glove_step6', 'glove.png');
    add_image('glove_step6_2', 'glove.png');
    add_image('glove_step6_3', 'glove.png');
    $('#glove_step6_3').css( {position: 'fixed'} );
    resize_action(step6_images_position);
    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '7') {
    $('html').append('<div id="cat_1"></div>');
    step7_images_position();
    resize_action(step7_images_position);
    block_a('class', 'id_link');
    $(".id_link").bind("click", function(event) {
      step_cookie_set(step, '/');
    });
  }

  if (step == '8') {
    $("body").on("column_resize", step8_images_position);
    $('html').append('<div id="cat_2"></div>');
    add_image('glove_step8', 'glove.png');
    $('#glove_step8').css( {position: 'fixed'} );
    resize_action(step8_images_position);
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

  if (step == '9' || step == '11') {
    $('html').append('<div id="cat_2"></div>');
    step9_images_position();
    resize_action(step9_images_position);
    block_a('class', "new_claim_link");
    $(".new_claim_link").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '10' || step == '12') {
    $("body").on("column_resize", step6_images_position);
    $('html').append('<div id="cat_1"></div>');
    add_image('glove_step6', 'glove.png');
    add_image('glove_step6_2', 'glove.png');
    add_image('glove_step6_3', 'glove.png');
    $('#glove_step6_3').css( {position: 'fixed'} );
    resize_action(step6_images_position);
    block_a('class', "save");
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '13') {
    var clicks = {
      arrival_date: 0,
      check_date: 0,
      approved_operator_advance_prim: 0
    }

    $("a").bind("click", function(event) {
      if (!$(event.target).parents('.claims_header').length == 1){
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

  if (step == '14') {
    block_a('id', 'add_potential');
    $("#add_potential").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

  if (step == '15') {
    block_a('class', 'save');
    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });
  }

});