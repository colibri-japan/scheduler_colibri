$(document).on 'turbolinks:load', ->

  $('input[name="posts_date_range"]').focus ->
    $(this).daterangepicker
      timePicker: true
      timePicker24Hour: true
      timePickerIncrement: 15
      startDate: moment().set({'hour': 6, 'minute': 0})
      endDate: moment().set({ 'hour': 21, 'minute': 0})
      locale: 
        format: 'M月DD日 H:mm'
        applyLabel: "選択する"
        cancelLabel: "取消"
        fromLabel: ""
        toLabel: "から"
        daysOfWeek: [
          "日"
          "月"
          "火"
          "水"
          "木"
          "金"
          "土"
        ]
        monthNames: [
          "1月"
          "2月"
          "3月"
          "4月"
          "5月"
          "6月"
          "7月"
          "8月"
          "9月"
          "10月"
          "11月"
          "12月"
        ]
        firstDay: 1
    return
  
  $('#posts-search-button').click ->
    if $('#posts_date_range').data('daterangepicker')
      range_start = $('#posts_date_range').data('daterangepicker').startDate.format('YYYY-MM-DD H:mm')
      range_end = $('#posts_date_range').data('daterangepicker').endDate.format('YYYY-MM-DD H:mm')
    
    queryData =
      range_start: range_start,
      range_end: range_end,
      patient_ids: $('#posts_patient_ids_filter').val()
      author_ids: $('#posts_author_ids_filter').val()
    $.ajax
      url: '/posts.js'
      data: queryData
    return

  if $('#index-container').length > 0
    clickableTableRowPost() 


  return
