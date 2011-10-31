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

$(function() {

  $('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });

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

  // All autocomplete parameters in here
  var $autocomplete = {
    touristLastName: {
      source: "/claims/autocomplete_tourist_last_name",
      select: function(event, ui) {
        var tr = $(event.target).parent().parent();
        tr.find("input.passport_series").val(ui.item.passport_series);
        tr.find("input.passport_number").val(ui.item.passport_number);
        tr.find("input.date_of_birth").val(ui.item.date_of_birth);
        tr.find("input.passport_valid_until").val(ui.item.passport_valid_until);
      }
    }
  };

  $("input.autocomplete.full_name").autocomplete($autocomplete.touristLastName);

});
