jQuery ->
  $(".tasks .bug_checkbox").on "change", ->
      row = $(this).closest("tr")
      task_id = @value
      $.ajax(
        type: "POST"
        url: "/tasks/" + task_id + "/bug"
        data:
          state: (if (@checked) then 1 else 0)

        dataType: "json"
        context: this).done (data) ->
          if data
            row.addClass "bug"
          else
            row.removeClass "bug"
  $(".filter_frm select").change ->
    $(this.form).trigger('submit');
