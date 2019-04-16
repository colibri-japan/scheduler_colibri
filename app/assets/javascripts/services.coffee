$(document).on 'turbolinks:load', ->
  
  $('.service-clickable-row').click ->
    $.getScript($(this).data('link'))
    return
  return