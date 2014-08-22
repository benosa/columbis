var step = $('html').data('start_trip_step');

function step_cookie_set(step, path) {
  var currentDate = new Date();
  expirationDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()+3, 0, 0, 0);
  $.cookie('start_trip_step', step, {expires: expirationDate, path: path});
}

function step1_images_position() {
  var offset = $('.save').offset();
  $('#glove_step1').offset({ top: offset.top, left: offset.left - 100});
  offset = $('#company_name').offset();
  $('#cat_1').offset({ top: offset.top, left: offset.left + 140 });
  $('#cloud1_step1').offset({ top: offset.top -50, left: offset.left + 310});
  $('#cloud2_step1').offset({ top: offset.top, left: offset.left + 810});
}

function step2_images_position() {
  var offset = $('#add_worker').offset();
  $('#cat_2').offset({ top: offset.top - 250, left: offset.left - 200});
 // $('#cat2').offset({ top: - 100, left: 100});
}

function step3_images_position() {
  var offset = $('.save').offset();
  $('#cat_2').offset({ top: offset.top - 250, left: offset.left - 200});
  $('#cloud1_step3').offset({ top: offset.top - 550, left: offset.left - 1200});
  $('#cloud2_step3').offset({ top: offset.top - 550, left: offset.left - 600});
}

function add_image(id, name) {
  var img = $('<img id="' + id + '">');
  img.attr('src', '/assets/start_trip/' + name);
  img.appendTo('html');
}

$(function(){
  //var step = $('html').data('start_trip_step');

  if (step == '1') {
    // cat
    $('html').append('<div id="cat_1"></div>');
    // glove
    add_image('glove_step1', 'glove.png');
    $('#glove_step1').css({position: 'fixed'});
    // genius text left
    add_image('cloud1_step1', 'columbis-31.png');
    // genius text right
    add_image('cloud2_step1', 'columbis-32.png');

    step1_images_position();

    $(".save").bind("click", function() {
      step_cookie_set(step, '/')
    });

    var resizeId;
    $(window).resize(function() {
      clearTimeout(resizeId);
      resizeId = setTimeout(step1_images_position, 200);
    });
  }

  if (step == '2') {
    $('html').append('<div id="cat_2"></div>');
  //  $('#cat2').offset({ top: 100, left: 100});
    $('#cat_2').css({position: 'fixed'});
    step2_images_position();

    var resizeId;
    $(window).resize(function() {
      clearTimeout(resizeId);
      resizeId = setTimeout(step2_images_position, 200);
    });
  }

  if (step == '3') {
    $('html').append('<div id="cat_2"></div>');
    $('#cat_2').css( {position: 'fixed'} );
    add_image('cloud1_step3', 'columbis-41.png');
    $('#cloud1_step3').css({position: 'fixed'});
    add_image('cloud2_step3', 'columbis-42.png');
    $('#cloud2_step3').css({position: 'fixed'});
    step3_images_position();

    var resizeId;
    $(window).resize(function() {
      clearTimeout(resizeId);
      resizeId = setTimeout(step3_images_position, 200);
    });
  }

});