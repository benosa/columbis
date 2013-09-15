$(function() {
  disabled_password_block( is_use_office_password_active() );

  $('#use_office_password_label').on('click', function(e) {
    disabled_password_block( !is_use_office_password_active() );
  });
});

function is_use_office_password_active() {
  return $('#use_office_password_label').hasClass('active');
};

function disabled_password_block(check) {
  if (check) {
    $('#password_block *').attr('disabled', true);
  } else {
    $('#password_block *').removeAttr('disabled');
  };
};