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
//	Destroy the editor.
  edit_html = editor.getData();
  editor.destroy();
	editor = null;
  $('#base_acts').show();
  $('#edit_acts').hide();
  if (!save) {
    $('#edit_content').html(html);
  } else {
    $.ajax({
      url: $('body').data('update_path'),
      type: 'post',
      data: { _method: 'put', body: edit_html },
      success: function(data) {
        alert('olo');
      }
    });
  }
}

$(function(){
  $('#edit_acts').hide();
  $('a#create_editor').on('click', function(){
    createEditor();
  });
  $('a#close_editor').on('click', function(){
    removeEditor(0);
  });
  $('a#save_editor').on('click', function(){
    removeEditor(1);
  });
});

