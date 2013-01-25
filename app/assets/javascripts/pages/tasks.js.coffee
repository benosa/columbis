jQuery ->

  task_update = (task_id, options, do_after_callback = true) ->
    $task = $("#task-#{task_id}")
    defaults =
      url: '/tasks/' + task_id
      data:
        _method: 'PUT'
      context: $task
      type: 'POST'
      dataType: 'script'

    opts = $.extend(true, {}, defaults, options)
    $ajax = $.ajax(opts)
    $ajax.done(after_task_update) if do_after_callback is on
    $ajax

  after_task_update = (data) ->
    $task = this
    $task.find('.popup_hover').popover('hide') # hide visible popover, otherwise it stays after replace
    $task.replaceWith(data)

  $(".tasks").on "change", '.bug_checkbox', ->
    task_id = @value
    task_update @value,
      url: "/tasks/#{task_id}/bug"
      data:
        state: (if (@checked) then 1 else 0)

  $(".filter_frm select").change ->
    $(this.form).trigger('submit');

  $('.tasks').popover
    selector: '.popup_hover'
    trigger: 'hover'
    placement: 'right'

  comment_show = (el)->
    $el = $(el)
    comment_close()
    $form = $('#comment_form_container .comment_form').clone()
    $form.attr
      'data-task': $el.closest('.task').data('id'),
      'data-action': if $el.hasClass('finish_task') then 'finish' else 'cancel'
    $el.popover
      html: true
      trigger: 'manual'
      placement: 'bottom'
      content: $form
      title: $form.data('title')
    $el.addClass('comment-active').popover('show')

  comment_close = ->
    $(".tasks .comment-active").removeClass('comment-active').popover('destroy')

  # Finish and cancel task actions
  $('.tasks').on "click", '.finish_task, .cancel_task', (e)->
    e.preventDefault()
    comment_show(this) unless $(this).hasClass('comment-active')

  # Actions of comment form
  $(document.body).on 'click', '.comment_form .save_btn, .comment_form .close_btn', (e)->
    e.preventDefault()
    $form = $(this).closest('.comment_form')
    task_id = $form.data('task')
    action = $form.data('action')

    if $(this).hasClass('save_btn') # save button is selected
      $form.closest('.popover').addClass('task_comment_popover') # task list will be replaced after update, mark popover with comment class
      task_update task_id,
        data:
          'task[status]' : action
          'task[comment]': $form.find('.task_comment').val()
        , false
      .done ->
        $('.task_comment_popover').remove()
      .done(after_task_update)
    else
      comment_close()