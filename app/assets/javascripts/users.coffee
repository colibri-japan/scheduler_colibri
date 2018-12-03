$(document).on 'turbolinks:load', ->

  $('.user-clickable-row').click ->
    $.getScript($(this).data('url'));
    return
    
  return