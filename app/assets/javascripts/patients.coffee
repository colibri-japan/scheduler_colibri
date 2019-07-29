# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

patientSelect2 = ->
  $('#patient_caveat_list').select2
    tags: true,
    theme: 'bootstrap',
    language: 'ja'
  return

$(document).on 'turbolinks:load', ->
  
  $('tr.patient-clickable-row').click ->
    $.getScript($(this).data('link'))
    return 

  $('#deactivated-patients').click ->
    $('.toggle-active-element').removeClass('toggle-active-selected')
    $(this).addClass('toggle-active-selected')
    $('#deactivated-patients-table').show()
    $('#active-patients-table').hide()
    return

  $('#active-patients').click ->
    $('.toggle-active-element').removeClass('toggle-active-selected')
    $(this).addClass('toggle-active-selected')
    $('#deactivated-patients-table').hide()
    $('#active-patients-table').show()
    return

  $('.edit_hiwari_count').click ->
    $('#calculate_hiwari_days').modal('show')
    return

  $('#patient_date_of_contract').focus ->
    $(this).daterangepicker
      singleDatePicker: true 
      locale: 
        format: 'YYYY-MM-DD'
        applyLabel: '選択する'
        cancelLabel: "取消"
        daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土"
        ]
        monthNames: [
          "1月",
          "2月",
          "3月",
          "4月",
          "5月",
          "6月",
          "7月",
          "8月",
          "9月",
          "10月",
          "11月",
          "12月"
        ]
        firstDay: 1
    return

  $('#patient_end_of_contract').focus ->
    $(this).daterangepicker
      singleDatePicker: true 
      locale: 
        format: 'YYYY-MM-DD'
        applyLabel: '選択する'
        cancelLabel: "取消"
        daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土"
        ]
        monthNames: [
          "1月",
          "2月",
          "3月",
          "4月",
          "5月",
          "6月",
          "7月",
          "8月",
          "9月",
          "10月",
          "11月",
          "12月"
        ]
        firstDay: 1
    return

    
  return