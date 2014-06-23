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

ajax_delete_comment = () ->
  $('.delete_tourist_comment').on 'click', (e)->
    e.preventDefault()
    if confirm('Удалить?')#$('.upload_images').data('confirm'))
      $.ajax
        context: @
        url: this.href
        type: 'post'
        data: { _method: 'put' }
        success:(resp)->
          if (resp.id)
            $('#tourist_comment_' + resp.id).remove()

jQuery ->
  $('.tasks_block .disbled').attr('disabled', 'disabled')

  $('#refusal_reason').on 'change', (e)->
    $('#tourist_refused_note').attr('value', $(this).val())

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

  # Add comment
  $('#add_tourist_comment').on 'click', (e)->
    e.preventDefault()
    if $('#comment_body').val()
      $.ajax
        context: @
        url: this.href
        type: 'post'
        data: { _method: 'put', body: $('#comment_body').val() }
        success:(resp)->
          if (resp.id)
            $('#tourist_comments_list').prepend('<div id="tourist_comment_' + resp.id + '" class="comment">' +
            '<span class="date_name">' + resp.name + ' ' + resp.date + '</span> ' +
            '<span class="body">' + resp.body + '</span>' +
            ' <a class="delete_tourist_comment" href="' + resp.path + '">X</a></div>')
            ajax_delete_comment()

  #Delete comment
  ajax_delete_comment()

  #Add task
  $('#add_tourist_task').on 'click', (e)->
    e.preventDefault()
    last_id = $('#tourist_tasks .task_block:last input:last').attr('id')
    if last_id then num = parseInt last_id.replace(/\D/g, '') else num = -1
    name = $('#new_task_name').val().trim()
    user = $('.tasks_block').data('current_user')
    if name != ''
      tmpl = JST['tourists/task'].render(id: num + 1, name: name, user: user)
      $('.tasks_block').append(tmpl)

  #delete task
  $('#tourist_tasks').on 'click', '.del', (e)->
    e.preventDefault()
    if confirm('Уверены, что хотите удалить?')
      $f = $(@).closest('.task_block')
      if $f.length && $f.find(':hidden[name*=_destroy]').length
        $f.find(':hidden[name*=_destroy]').val('1')
        $f.hide()
      else
        $f.remove()

  $('.tourist_task_state').on 'change', (e)->
    $t_block = $(@).closest('.task_block')
    if $(@).attr('checked')
      $t_block.find('.tourist_task_state_input').val('done')
      user = $('.tasks_block').data('current_user')
      $t_block.find('.name_field').attr('disabled', 'disabled')
    else
      if !$(@).hasClass('new')
        confirm_message = $t_block.data('close_by')
        if confirm_message != ''
          if confirm(confirm_message)
            $t_block.find('.tourist_task_state_input').val('new')
            user = $t_block.data('user')
            $t_block.find('.name_field').removeAttr('disabled')
          else
            $(@).attr('checked', 'checked')
        else
          $t_block.find('.tourist_task_state_input').val('new')
          user = $t_block.data('user')
          $t_block.find('.name_field').removeAttr('disabled')

    $t_block.find('.tourist_task_user_input').val(user)


