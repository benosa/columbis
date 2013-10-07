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

  $.each($('input.image_upload'), (i, e) -> UploaderCheck.init($(e)))

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
    UploaderCheck.init($form.find('input.image_upload'))
    $form.find('.close_btn').on 'click', review_close
    $form.find('.file input[type=file]').bind('change focus click', SITE.fileInputs)
    $el.popover
      html: true
      trigger: 'manual'
      placement: 'bottom'
      content: $form
      title: $form.data('title')
    $el.addClass('review-active').popover('show')
    $('.popover.fade.bottom.in').attr("style", "top:100px; left:0px; display:block;")
    $('.popover.fade.bottom.in').attr("class", $('.popover.fade.bottom.in').attr("class") + " review_popup")

  review_close = ->
    $(".review-active").removeClass('review-active').popover('destroy')

  # Write review
  $('a.write_review').on "click", (e)->
    e.preventDefault()
    unless $(document.body).hasClass('review-active')
      review_show(document.body)
    else
      review_close()

  # Close review
  $(document.body).on 'click', '.review_form .close_btn', (e)->
    review_close()

UploaderCheck =
  input: null
  max_size: 5
  file_size: null
  message_box: null
  file: null
  name_error: false
  size_error: false
  extensions: ['jpg', 'jpeg', 'gif', 'png']

  init: (element) ->
    if !window.FileReader then return
    this.message_box = element.parent().next()
    if this.message_box == undefined then return
    extensions = this.message_box.attr('data-extensions')
    size = this.message_box.attr('data-size')
    if extensions != undefined
      this.extensions = extensions.split(',')
    if size != undefined
      this.max_size = parseFloat(size)
    this.checker(element)
    this.bind_checker(element)

  check_size: ->
    this.file_size = (this.file.size/1000/1000).toFixed(1)
    if this.file_size > this.max_size
      this.size_error = true

  check_name: ->
    if this.extensions[0] != 'true'
      file_name = this.file.name.split('.')
      file_name = file_name[file_name.length-1].toLowerCase()
      this.name_error = !this.extensions.some((x) -> x == file_name)

  bind_checker: (element) ->
    element.on 'change', -> UploaderCheck.checker($(this))

  check_errors: (element) ->
    if this.size_error || this.name_error
      if this.size_error
        this.message_box.text(this.message_box.text() + "Слишком большой размер. ")
      if this.name_error
        this.message_box.text(this.message_box.text() + "Не верный формат файла. ")
      # Add form because reset function don't work without form tag )))
      element.wrap('<form>').closest('form').get(0).reset()
      element.unwrap()
    else
      this.message_box.text(this.message_box.text() + "Файл имеет размер " + this.file_size + " МБ. ")

  clear_before_check: ->
    this.message_box.text("")
    this.name_error = false
    this.size_error = false

  checker: (element) ->
    this.input = element[0]
    this.clear_before_check()
    if (this.input != undefined) && (this.input.files != undefined) && (this.input.files.length != 0)
      this.file = this.input.files[0]
    else
      this.file = null
    if this.file != null
      this.check_name()
      this.check_size()
      this.check_errors(element)