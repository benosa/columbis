jQuery ->

  task_update = (task_id, options) ->
    $task = $("#task-#{task_id}")
    data = $.extend(getParamsData(), { _method: 'PUT' })
    defaults =
      url: "/tasks/#{task_id}"
      data: data
      context: $task
      type: 'POST'
      dataType: 'script'

    opts = $.extend(true, {}, defaults, options)
    $ajax = $.ajax(opts)

  task_create = (form, options) ->
    data = $.extend(getParamsData(), { _method: 'POST' })
    defaults =
      url: "/tasks"
      data: data
      context: form
      type: 'POST'
      dataType: 'json'

    opts = $.extend(true, {}, defaults, options)
    $ajax = $.ajax(opts)

  # after_task_update = ($task) ->
  #   $task.find('.popup_hover').popover('hide') # hide visible popover, otherwise it stays after replace
  #   $task.replaceWith(data)

  $(".tasks").on "change", '.bug_checkbox', ->
    task_update @value,
      data:
        'task[bug]': @checked

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
      .done ->
        $('.task_comment_popover').remove()
    else
      comment_close()

  review_show = (el)->
    $el = $(el)
    $form = $('#review_form_container .review_form').clone()
    $form.find('.close_btn').on 'click', review_close
    $el.popover
      html: true
      trigger: 'manual'
      placement: 'bottom'
      content: $form
      title: $form.data('title')
    $el.addClass('review-active').popover('show')

  review_close = ->
    $(".review-active").removeClass('review-active').popover('destroy')

  # Write review
  $('#write_review').on "click", (e)->
    e.preventDefault()
    unless $(this).hasClass('review-active')
      review_show(this)
    else
      review_close()

  # Close review
  $(document.body).on 'click', '.review_form .close_btn', (e)->
    review_close()
