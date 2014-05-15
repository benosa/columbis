set_tourists_tooltip = (init)->
  options =
    template: '<div class="tooltip white"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
    placement: 'bottom'
    container: 'body'
    delay: 100
    animation: false
    trigger: 'manual'

  $('#tourists td[title]').each ->
    if !$(@).hasClass('with_tooltip')
      $(@).tooltip(options).addClass('with_tooltip')

  if init
    $('body')
      .on('click', '.tourists .with_tooltip', (e)-> $(@).tooltip('toggle'))
      .on('mouseout', '.tourists .with_tooltip', (e)->
        if @ != $(e.currentTarget).parent().get(0)
          $(@).tooltip('hide')
      )

jQuery ->
  if $('.tourist_list').length
    set_tourists_tooltip(true)
    $('body').on 'refreshed', '.current_container', (e)->
      set_tourists_tooltip()

  # Form
  $('.tourist.edit_operator textarea').autosize()
  $('.tourist.edit_operator .state input[type=checkbox]').on 'change', (e)->
    $states = $('.tourist.edit_operator .state').not $(this).closest('.state')
    $states.find('label.checkbox').removeClass('active')
    $states.find('input[type=checkbox]').attr('checked', false)

  # Add file
  $('#files_block').on 'click', '.add', (e)->
    e.preventDefault()
    last_id = $('#files_block .new_file:last input[type=file]').attr('id')
    if last_id then num = parseInt last_id.replace(/\D/g, '') else num = 0
    tmpl = JST['tourists/file'].render(id: num + 1)
    $('#add_file_block').before(tmpl)
    $('#files_block .new_file.new_record').removeClass('new_record')
      .find('.file input[type=file]').bind('change focus click', SITE.fileInputs)
    check_add_file()

  check_add_file = ()->
    files_count = $('#files_block .file_link').length
    new_files_count = $('#files_block .new_file').length
    if files_count + new_files_count > 10 then $('#add_file_block').hide() else $('#add_file_block').show();

  # Delete file
  $('#files_block').on 'click', '.del', (e)->
    e.preventDefault()
    $f = $(@).closest('.file_link')
    if $f.length && confirm($(@).data('confirm-text'))
      $f.find(':hidden[name*=_destroy]').val('1')
      $f.hide()
    else
      $f = $(@).closest('.new_file')
      $f.remove()
      unless $('#files_block .new_file').length
        $('#files_block .add').trigger('click')
    check_add_file()
