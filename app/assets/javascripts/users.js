$(function() {
  disabled_password_block( is_use_office_password_active() );
  bind_to_checkbox_data_message( $('#use_office_password_label') );

  $('#use_office_password_label').on('click', function(e) {
    disabled_password_block( !is_use_office_password_active() );
  });
});