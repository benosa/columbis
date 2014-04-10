$(function() {
  var palette = $("#user_color").attr('data-pallete');
  if (palette) { palette = palette.split(','); }

  $("#user_color").spectrum({
    cancelText: $("#user_color").attr('data-cansel_text'),
    chooseText: $("#user_color").attr('data-chose_text'),
    showInput: false,
    className: "full-spectrum",
    showInitial: true,
    showPalette: true,
    showSelectionPalette: true,
    palette: palette,
    showAlpha: false,
    preferredFormat: "hex"
  });

  var OfficeWithPassword = {
    use_office_selector: $('select#user_office_id'),
    use_office_label: $('#use_office_password_label'),
    use_office_checkbox: $('#user_use_office_password'),
    password_block: '#password_block',
    offices: null,

    init: function() {
      var checken_office = $('#user_office_id option[selected="selected"]').attr('value');
      if (checken_office == undefined) {
        checken_office = $('#user_office_id option').first().attr('value');
      }
      this.offices = this.use_office_label.attr('checkable_offices');
      $('select#user_office_id').change(function() {
        OfficeWithPassword.change_select_block(this.value);
      });
      this.use_office_label.on('click', function() {
        OfficeWithPassword.change_password_block(false);
      });
      this.change_select_block(checken_office);
      bind_to_checkbox_data_message(this.use_office_label);
    },

    change_select_block: function(office_id) {
      if (this.offices != undefined && this.offices != "" && $.inArray(office_id, this.offices.split(',')) != -1) {
        this.enabled_checkbox_use_office(true);
      } else {
        this.enabled_checkbox_use_office(false);
      }
      this.change_password_block(true);
    },

    change_password_block: function(is_init) {
      var condition = this.use_office_label.hasClass('active');
      if (!is_init) {
        condition = !condition;
      }
      if (condition) {
        if (!this.use_office_label.hasClass('disabled')) {
          $(this.password_block + " *").attr('disabled', true);
        }
      } else {
        $(this.password_block + " *").removeAttr('disabled');
      };
    },

    enabled_checkbox_use_office: function(is_enabled) {
      if(is_enabled) {
        this.use_office_label.removeClass('disabled');
      } else {
        this.use_office_label.addClass('disabled');
        this.use_office_label.removeClass('active');
        this.use_office_checkbox.removeAttr('checked');
      }
    }
  }

  OfficeWithPassword.init();
});