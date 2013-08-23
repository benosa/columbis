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