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
          $('#claim_tourist_attributes_id').val(ui.item.id);
        } else {
          input = tr.next();
        }
      }
    }
  };
  $("input.autocomplete.full_name").autocomplete($autocomplete.touristLastName);

  // add tourist
	var add_tourist = function(e){
    e.preventDefault();
    
    $('#tourists .footer').before($('#new_tourist').clone());
    $('#tourists #new_tourist').attr('id', '').addClass('dependent');

    var last_ind = 0;
    $('#tourists tr.dependent').each(function(i){
      $(this).attr('id','dependent' + (i+2));

      $(this).find('a.del').click(del_tourist);
      $(this).find('a.del').attr('id','del'+(i+2));

      $(this).find('input.autocomplete.full_name').autocomplete($autocomplete.touristLastName);
      $(this).find('.num').text(i+2)
      last_ind = i+1;
    });
    //$('#tourists .footer').before('<input id=​"claim_tourists_attributes_0_id" name=​"claim[tourists_attributes]​[0]​[id]​" type=​"hidden">​');
	}
	$('#tourists a.add').click(add_tourist);

  // del tourist
  var del_tourist = function(e){
    e.preventDefault();
    var id = $(this).attr('id').replace(/del/,'');
    if (id == 1) {
      $('.applicant input').val('');
      $('.applicant').next().find('input').val('');
      $('#claim_tourist_attributes_id').removeAttr('value');
    } else {
      $('#tourists #dependent' + id).next('input[type=hidden]').remove();
      $('#tourists #dependent' + id).remove();
    }

    $('#tourists tr dependent').each(function(i){
      $(this).find('.num').text(i+2)
      $(this).find('.del').attr('id','del'+(i+2));
      $(this).attr('id','dependent'+(i+2));
    });
  }
	$('#tourists a.del').click(del_tourist);
});
