$(function(){
  $('a#add_text_link').on('click', function(e){
    e.preventDefault();
    //CKEDITOR.instances.IDofEditor.insertText('some text here')
    CKEDITOR.instances['doc_body'].insertText('str');
   // console.log(CKEDITOR.instances)
    //alert('11');
  });
});
