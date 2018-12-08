  
$(document).on 'turbolinks:load', ->

  $('#account-edit').click ->
    $('#account-delete-body').hide()
    $('#account-edit-body').show()
    $('.account-menu-item').removeClass('account-menu-selected')
    $(this).addClass('account-menu-selected')
    return

  $('#account-delete').click ->
    $('#account-edit-body').hide()
    $('#account-delete-body').show()
    $('.account-menu-item').removeClass('account-menu-selected')
    $(this).addClass('account-menu-selected')
    return

  return