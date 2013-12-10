var editor, html = '';

function createEditor() {
	if ( editor )
		return;
	// Create a new editor inside the <div id="editor">, setting its value to html
	var config = { height: '600px' };
  hideEmptyFields();
  $('#base_acts').hide();
  $('#edit_acts').show();
  html = $('#edit_content').html();
  editor = CKEDITOR.replace( 'edit_content', config);
}

function removeEditor(save) {
	if ( !editor )
		return;

  edit_html = editor.getData();

  $('#base_acts').show();
  $('#edit_acts').hide();
  if (!save) {
    editor.destroy();
    editor = null
    $('#edit_content').html(html);
  } else {
    $.ajax({
      url: $('body').data('update_path'),
      type: 'post',
      data: { _method: 'put', body: edit_html },
      success: function(data) {
        if (data.success == true) {
          $('#delete_doc').removeClass('hidden');
          editor.destroy();
          editor = null;
        }
      }
    });
  }
}

function delete_doc() {
  $.ajax({
    url: $('body').data('delete_path'),
    type: 'post',
    data: { _method: 'put' },
    success: function(data) {
      if (data.success == true) {
        $('#delete_doc').addClass('hidden');
        $('#edit_content').html(data.html);
      }
    }
  });
}

function showEmptyFields() {
  var el = document.getElementById('empty_fields');
  if (el && !el.innerHTML.match('#{ПУСТЫЕ_ПОЛЯ}')) {
    el.style.height = 'auto';
    el.style.display = 'block';
  }
};

function hideEmptyFields() {
  var el = document.getElementById('empty_fields');
  if (el) {
    el.style.height = '0px';
    el.style.display = 'none';
  }
}

if (window.addEventListener)
  window.addEventListener('load', showEmptyFields, false);
else if (window.attachEvent)
  window.attachEvent('onload', showEmptyFields );


$(function(){
  $('#edit_acts').hide();
  $('a#create_editor').on('click', function(){
    createEditor();
  });
  $('a#close_editor').on('click', function(){
    removeEditor(0);
  });
  $('a#delete_doc').on('click', function(){
    if (confirm($('body').data('delete_message'))) {
      delete_doc()
    }
  });
  $('a#save_editor').on('click', function(){
    removeEditor(1);
  });
});


