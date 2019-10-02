# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

  $('tr.clickable-row').click ->
    window.location = $(this).data('link')
    return

  $('.print-option-checkbox').bootstrapToggle
    on: '有',
    off: '無',
    size: 'small',
    onstyle: 'primary',
    offstyle: 'secondary',
    width: 55

  $('#nurse-filter-zentai_').on 'change', ->
    $('.calendar').fullCalendar('rerenderEvents')
    return

  $('#patient-filter-zentai_').on 'change', ->
    $('.calendar').fullCalendar('rerenderEvents')
    return

  $('#master-nurse-filter-zentai_').on 'change', -> 
    $('.master_calendar').fullCalendar('rerenderEvents')

  $('#master-patient-filter-zentai_').on 'change', ->
    $('.master_calendar').fullCalendar('rerenderEvents')


  $('.colibri-clickable-link').click ->
    if $('#resource-container').length > 0
      window.resourceScroll = $('#resource-container')[0].scrollTop
    else
      window.resourceScroll = null
    Turbolinks.visit($(this).data('url'))
    return
  
  $('#toggle-patients-nurses').bootstrapToggle
    on: '利用者',
    off: '従業員',
    onstyle: 'info',
    offstyle: 'info',
    width: 100

  $('#toggle-patients-nurses').on 'change', ->
    $('#patients-resource').toggleClass('hide-resource')
    $('#nurses-resource').toggleClass('hide-resource')
    return
  

  $('#print-button').click ->
    if window.printDates == false
      $('.fc-day-header.fc-mon').html('月')
      $('.fc-day-header.fc-tue').html('火')
      $('.fc-day-header.fc-wed').html('水')
      $('.fc-day-header.fc-thu').html('木')
      $('.fc-day-header.fc-fri').html('金')
      $('.fc-day-header.fc-sat').html('土')
      $('.fc-day-header.fc-sun').html('日')
    window.print()
    return


  $('#colibri-master-action-button').click ->
    $.getScript($(this).data('url'))
    return
  
  $('#teams-report').click ->
    $('.modal').modal('hide')
    $('.modal-backdrop').remove()
    $('#remote-container').html($('#team-report-range'))
    $('#team-report-range').modal('show')
    downloadTeamsReport()
    return

  $('#report_range').daterangepicker
    locale: 
      format: 'M月DD日'
      applyLabel: "選択する"
      cancelLabel: "取消"
      fromLabel: ""
      toLabel: "から"
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
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
        "12月",
      ]
      firstDay: 1

  $('#toggle-switch-patients').click ->
    $(this).hide()
    $('#toggle-switch-nurses').show()
    $('#patients-resource').hide()
    $('#nurses-resource').show()
    return
  
  $('#toggle-switch-nurses').click ->
    $(this).hide()
    $('#toggle-switch-patients').show()
    $('#patients-resource').show()
    $('#nurses-resource').hide()
    return

  $('#nurse-search-button').click -> 
    alert('search nurse')

  if $('#colibri-salary-rules-index').length > 0
    $.getScript('/salary_rules.js')
      

  $('#service-type-filter').click ->
    $('#service_type_filter_content').toggle()
    return

  if $('#category-subcontainer').length > 0
    $.getScript('/appointments_by_category_report/appointments?y=' + $('#query_year').val() + '&m=' + $('#query_month').val())

  if $('#cm_filter').length > 0
    $('#cm_filter').selectize 
      plugins: ['remove_button']
      placeholder: '検索する...'
    filterCmCorporations()

  if $('#cm_teikyohyo_filter').length > 0
    $('#cm_teikyohyo_filter').selectize 
      plugins: ['remove_button']
      placeholder: '検索する...'
    filterCmTeikyohyo()

  if $('#revenue-report').length > 0
    $.getScript('/monthly_revenue_report/appointments')

  if $('#revenue-per-team-and-employee').length > 0
    $.getScript($('#revenue-per-team-and-employee').data('url'))

  if $('#revenue-per-team-report').length > 0
    $.getScript($('#revenue-per-team-report').data('url'))

  return
