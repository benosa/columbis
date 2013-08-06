(($) ->
  $.fn.extend limiter: (limit, elem) ->
    setCount = (src, elem) ->
      chars = src.value.length
      if chars > limit
        src.value = src.value.substr(0, limit)
        chars = limit
      elem.html limit - chars
    $(this).on "keyup focus", ->
      setCount this, elem

    setCount $(this)[0], elem

) jQuery