$(function(){
  // add printer
  $('#printers_block').on('click', '.add', function(e) {
    e.preventDefault();

    var printer = { id: $('#printers_block .fields').length },
        tmpl = JST['companies/printer'].render(printer),
        $new_printer = $(tmpl).insertBefore('#add_printer_block');
    customizeSelect($new_printer, true);
    $new_printer.find('input[type=file]').bind('change focus click', SITE.fileInputs);
    new_printer_country_check($new_printer);
    new_printer_set_tooltips($new_printer);
  });

  // delete printer
  $('#printers_block').on('click', '.del', function(e) {
    e.preventDefault();
    var $f = $(this).closest('.fields');
    if ($f.find('.new_file_form').length)
      $f.remove();
    else {
      $f.find(':hidden[name*=_destroy]').val('1');
      $f.hide();
    }
  });

  // add new file field for printer changing
  $('#printers_block').on('click', '.edit', function(e) {
    e.preventDefault();
    printer_toggle_edit_file_form(this);
  });

  function printer_toggle_edit_file_form(el) {
    var $f = $(el).closest('.fields'),
        $edit_file_form = $f.find('.edit_file_form');
    if ($edit_file_form.length) {
      $edit_file_form.remove();
      $f.find('.file_form').show();
    } else {
      var printer_id = $f.attr('id').replace(/\D+/, ''),
          printer = { id: printer_id },
          tmpl = JST['companies/printer'].render(printer);
          $file = $(tmpl).find('.file'),
          $del_file = $(tmpl).find('.del').toggleClass('del del_file')
          $edit_file_form = $('<div class="edit_file_form" />').append($file);
      $file.find('input[type=file]').bind('change focus click', SITE.fileInputs);
      $f.find('.file_form').after($edit_file_form).hide();
      $del_file.click(function(e) {
        e.preventDefault();
        printer_toggle_edit_file_form(this);
      });
      $edit_file_form.append($del_file);
    }
  }

  // show-hide country when mode changed
  $('#printers_block').on('change', 'select.mode_select', function(e) {
    var $t = $(this),
        mode = $t.val();
    new_printer_country_check($t.closest('.fields'), mode);
    // check printer with similar mode
    if (mode != 'memo' && $('#printers_block .fields[data-mode=' + mode + ']').length)
      toggle_tooltip($t.closest('.ik_select'));
  });

  $('#printers_block').on('change', 'select.country_select', function(e) {
    var $t = $(this),
        country_id = $t.val();
    // check memo printer with similar country
    if ($('#printers_block #country_' + country_id).length)
      toggle_tooltip($t.closest('.ik_select'));
  });

  //prepare fields
  function new_printer_country_check($new_printer, mode) {
    mode = mode || $new_printer.find('select.mode_select').val();
    if (mode != 'memo') {
      $new_printer.find('.country_label').hide();
      $new_printer.find('.ik_select.country_select').hide();
    } else {
      $new_printer.find('.country_label').show();
      $new_printer.find('.ik_select.country_select').show();
    }
  }

  function new_printer_set_tooltips($new_printer) {
    // tooltip for mode and coutry selects
    $new_printer.find('.ik_select.mode_select, .ik_select.country_select').tooltip({
      placement: 'top',
      trigger: 'manual',
      title: function() {
        return $(this).find('select').data('tooltip');
      }
    });
  }
});