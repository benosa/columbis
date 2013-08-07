jQuery ->

  columnWidths  = [1280, 1920, 2560]
  smallFormWidths = [979, 785, 785]
  blocks = ['tourists', 'route', 'flights', 'tour_price', 'payments_in', 'payments_out', 'information']
  blockPriorities =
    1: [0, 1, 2, 3, 4, 5, 6]
    2: [0, 3, 1, 4, 2, 5, -1, 6]
    3: [0, 3, 4, 1, 2, 5, -1, -1, 6]
    4: [0, 3, 1, 2, 6, 4, 5]

  setColumns = ->
    curWidth = $(@).width()
    newColumns = 0
    for w, i in columnWidths
      if curWidth <= w
        curWidth = w
        newColumns = i + 1
        break
    newColumns = columnWidths.length + 1 unless newColumns

    # newColumns = if curWidth <= widths[0] then 1 else if curWidth <= widths[1] then 2 else 3

    $forms = $('#forms')
    colsmatch = $forms.attr('class').match(/cols(\d+)/)
    currentColumns = if colsmatch then parseInt(colsmatch[1]) else 1

    if currentColumns isnt newColumns
      if newColumns > 1 then $forms.addClass('cols') else $forms.removeClass('cols')
      $forms.removeClass("cols#{currentColumns}").addClass("cols#{newColumns}")
      $form_blocks = $forms.find('.form_block').detach()
      $form_col = $forms.find('.form_col:first').detach()
      $forms.empty()
      $forms.append $form_col.clone() for i in [1..newColumns]

      blockGroups = []
      blockOrder = blockPriorities[newColumns]
      for i in [0..blockOrder.length - 1]
        group = i % newColumns
        blockGroups[group] = [] unless blockGroups[group]
        blockGroups[group].push blocks[blockOrder[i]] if blockOrder[i] isnt -1

      $form_cols = $forms.find('.form_col')
      for group, i in blockGroups
        for block in group
          $form_blocks.filter("##{block}").appendTo $form_cols.eq(i)


    formColWidth = $forms.find('.form_col:first').width()
    smallFormWidth = smallFormWidths[0] # smallFormWidths[newColumns - 1]
    if formColWidth < smallFormWidth then $forms.addClass('small_forms') else $forms.removeClass('small_forms')

  $(window).resize setColumns
  setColumns()