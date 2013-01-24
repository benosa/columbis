jQuery ->
  $(".tasks").on "change", '.bug_checkbox', ->
      row = $(this).closest("tr")
      task_id = @value
      $.ajax(
        type: "POST"
        url: "/tasks/" + task_id + "/bug"
        data:
          state: (if (@checked) then 1 else 0)

        dataType: "text"
        context: this).done (data) ->
          $task = $('#task-' + @value)
          $task.find('.popup_hover').popover('hide') # hide visible popover, otherwise it stays after replace
          $task.replaceWith(data)

  $(".filter_frm select").change ->
    $(this.form).trigger('submit');

  $('.tasks').popover
    selector: '.popup_hover'
    trigger: 'hover'
    placement: 'right'