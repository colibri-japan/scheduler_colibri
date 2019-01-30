# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'turbolinks:load', ->
    $('#corporation_include_description_in_nurse_mailer').bootstrapToggle
        on: '表示する'
        off: '表示しない'
        size: 'small'
        onstyle: 'primary'
        offstyle: 'secondary'
        width: '120'
        height: '30'

    return
