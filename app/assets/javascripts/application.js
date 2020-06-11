// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require popper
//= require bootstrap
//= require bootstrap4-toggle.min
//= require moment.min
//= require daterangepicker
//= require Chart.bundle
//= require chartkick
//= require_tree .

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var myDefaultWhiteList = $.fn.tooltip.Constructor.Default.whiteList;

myDefaultWhiteList.a = ['data-remote', 'href']


let editAfterDate = () => {
  $('#delete-recurring-appointment').hide();
  $('#recurring_appointment_editing_occurrences_after option').each(function () {
    var $this = $(this);
    if ($this.val()) {
      var date = moment($(this).text(), 'YYYY-MM-DD');
      $this.text(date.format('M月D日以降'));
    }
  });
}


let toggleFulltimeEmployee = () => {
  $('#full-timer-toggle').bootstrapToggle({
    on: '正社員',
    off: '非正社員',
    size: 'normal',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170,
    height: 34
  });
}


let toggleReminderable = () => {
  $('#reminderable-toggle').bootstrapToggle({
    on: 'リマインダー送信',
    off: 'リマインダーなし',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170,
    height: 34
  })
}


let phoneMailRequirement = () => {
  if ($('#reminderable-toggle').is(':checked')) {
    $('#nurse_phone_mail').prop('required', true);
  }
  $('#reminderable-toggle').change(function(){
    if ($(this).is(':checked')) {
      $('#nurse_phone_mail').prop('required', true);
    } else {
      $('#nurse_phone_mail').prop('required', false);
    }
  })
}

let toggleMarkAsReadForAll = () => {
  $('#toggle_share_to_all').bootstrapToggle({
    on: '共有する',
    off: '共有しない',
    size: 'small',
    onstyle: 'info',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let toggleEditRequested = () => {
  let $this  = $('.edit-requested-toggle')
  let requested = $this.data('requested')
  let onText = requested ? '残す' : '追加する';
  let offText = requested ? '出す' : '追加しない';
  $this.bootstrapToggle({
    on: onText,
    off: offText,
    size: 'small',
    onstyle: 'success',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let toggleCancelled = () => {
  let $this  = $('.cancelled-toggle')
  let cancelled = $this.data('cancelled')
  let onText = cancelled ? '残す' : 'キャンセルする';
  let offText = cancelled ? 'キャンセル解除' : 'キャンセルなし';
  $this.bootstrapToggle({
    on: onText,
    off: offText,
    size: 'small',
    onstyle: 'danger',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let serviceLinkClick = () => {
  $('tr.clickable-row.service-clickable').click(function(){
    $.getScript($(this).data('service-link'), function(){
      $('#service_recalculate_previous_wages').bootstrapToggle({
        on: '反映する',
        off: '反映しない',
        onstyle: 'success',
        offstyle: 'secondary',
        width: 130
      })
    });
  })
}


let sendReminder = () => {
  $('#send-email-reminder').click(function () {
    let customSubject = $('#nurse_custom_email_subject').val();
    let customMessage = $('#nurse_custom_email_message').val();
    let customDays = $('#custom-email-days').val();
    let ajaxUrl = $(this).data('send-reminder-url');

    $.ajax({
      url: ajaxUrl,
      type: 'PATCH',
      data: {
        nurse: {
          custom_email_subject: customSubject,
          custom_email_message: customMessage, 
          custom_email_days: customDays
        }
      },
    })
  })
}


let saveUserRole = () => {
  $('#save-user-role').click(function () {
    var user_data;
    user_data = {
      user: {
        role: $('#user_role').val()
      }
    };
    $.ajax({
      url: $(this).data('update-role-url'),
      data: user_data,
      type: 'PATCH'
    });
  });
};





let toggleServiceHourBasedWage = () => {
  $('#service_hour_based_wage').bootstrapToggle({
    on: '時給',
    off: '単価',
    onstyle: 'secondary',
    offstyle: 'secondary',
    width: 130
  })
};

let initializeBatchActionForm = () => {
  $("#colibri-batch-action-button").popover('hide')
  $('input[name="date_range"]').daterangepicker({
    timePicker: true,
    timePicker24Hour: true,
    timePickerIncrement: 15,
    startDate: moment().set({'hour': 6, 'minute': 0}),
    endDate: moment().set({ 'hour': 21, 'minute': 0}),
    locale: {
      format: 'YYYY/M/D H:mm',
      applyLabel: "選択する",
      cancelLabel: "取消",
      fromLabel: "",
      toLabel: "から",
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
      ],
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
      ],
      firstDay: 1
    }
  })
}


let submitReflect = () => {
  $('#submit-reflect').one('click', function(event){
    event.preventDefault();
    let year = $('#master-reflect-year').val()
    let month = $('#master-reflect-month').val()
    let url = $(this).data('submit-url') + '?month=' + month + '&year=' + year;

    $.ajax({
      url: url,
      type: 'PATCH',
    })

    $(this).prop('disabled', true)
  })
}


let patientDatePicker = () => {
  let datepickerlocale = {
    format: 'YYYY-MM-DD',
    daysOfWeek: [
      "日",
      "月",
      "火",
      "水",
      "木",
      "金",
      "土",
    ],
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
    ],
    firstDay: 1
  }
  $('#patient_date_of_contract').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      showDropDowns: true,
      locale: datepickerlocale
    })
  })
}

let downloadTeamsReport = () => {
  $('#teams-report-download').click(function(){
    let range_start = $('#report_range').data('daterangepicker').startDate.format('YYYY-MM-DD');
    let range_end = $('#report_range').data('daterangepicker').endDate.format('YYYY-MM-DD');
    window.location.href = $(this).data('url') + '?range_start=' + range_start + '&range_end=' + range_end
  })
}

let scrollPosts = () => {
  if ($("#posts-container").length > 0) {
    $("#posts-container").scrollTop($("#posts-container")[0].scrollHeight)
  }
}

let wishedSlotRank = () => {
  if ($('#wished_slot_rank_2').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-yellow')
    $('#button_rank_2').addClass('btn-colibri-light-green')
  } else if ($('#wished_slot_rank_1').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-green btn-colibri-light-red')
    $('#button_rank_1').addClass('btn-colibri-light-yellow')
  } else if ($('#wished_slot_rank_0').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-yellow btn-colibri-light-green')
    $('#button_rank_0').addClass('btn-colibri-light-red')
  }
}

let wishedSlotChecked = () => {
  if ($('#wished_slot_rank_0').is(':checked')) {
    $('#button_rank_0').addClass('btn-colibri-light-red')
  } else if ($('#wished_slot_rank_1').is(':checked')) {
    $('#button_rank_1').addClass('btn-colibri-light-yellow')
  } else if ($('#wished_slot_rank_2').is(':checked')) {
    $('#button_rank_2').addClass('btn-colibri-light-green')
  }
}

let wishedSlotRadioLayout = () => {
  $('#button_rank_2').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-yellow btn-colibri-light-red");
    $(this).addClass("btn-colibri-light-green")
  })
  $('#button_rank_1').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-green btn-colibri-light-red");
    $(this).addClass("btn-colibri-light-yellow")
  })
  $('#button_rank_0').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-green btn-colibri-light-yellow");
    $(this).addClass("btn-colibri-light-red")
  })
}

let toggleCalendarEventModel = () => {
  $('#calendar-event-appointment-button').click(function () {
    $(this).addClass('btn-colibri-light-blue');
    $('#calendar-event-private-event-button').removeClass('btn-colibri-light-red');
    $('#private-event-form-container').hide();
    $('#appointment-form-container').show();
  });
  $('#calendar-event-private-event-button').click(function () {
    $(this).addClass('btn-colibri-light-red');
    $('#calendar-event-appointment-button').removeClass('btn-colibri-light-blue');
    $('#private-event-form-container').show();
    $('#appointment-form-container').hide();
  });
}

let autoFillResource = (resourceId, resourceLabel) => {
  if (resourceLabel == "利用者" || resourceLabel == "顧客") {
    $('#appointment_patient_id').val(resourceId);
    $('#private_event_patient_id').val(resourceId);
  } else if (resourceLabel == "従業員") {
    $('#appointment_nurse_id').val(resourceId);
    $('#private_event_nurse_id').val(resourceId);
  }
}

let selectSecondAppointmentCopyOption = () => {
  $('#second-option-selected-button').click(function(){
    $('#option2').show();
    $(this).hide();
    $('#third-option-selected-button').show()
  })
  $('#remove-second-option-button').click(function(){
    $('#option2').hide();
    if ($('#third-option-selected-button').is(':visible')) {
      $('#third-option-selected-button').hide()
    }
    $('#second-option-selected-button').show();
    $('#second_option_selected').prop('checked', false)
  })
  $('#third-option-selected-button').click(function(){
    $('#option3').show();
    $(this).hide();
  })
  $('#remove-third-option-button').click(function(){
    $('#option3').hide();
    $('#third-option-selected-button').show()
    if ($('#second-option-selected-button').is(':visible')) {
      $('#third-option-selected-button').hide();
    }
    $('#third_option_selected').prop('checked', false)
  })
}

let submitAppointmentCopyOption = () => {
  $('#create-appointments-trigger').one('click', function(event){
    event.preventDefault();
    $(this).prop('disabled', true);
    let ajaxData;
    ajaxData = {
      option1: {
        year: $('#reflect-year-1').val(),
        month: $('#reflect-month-1').val()
      },
      option2: {
        year: $('#reflect-year-2').val(),
        month: $('#reflect-month-2').val()
      },
      option3: {
        year: $('#reflect-year-3').val(),
        month: $('#reflect-month-3').val()
      },
      option2IsSelected: $('#second_option_selected').is(':checked'),
      option3IsSelected: $('#third_option_selected').is(':checked')
    }

    console.log(ajaxData)
    $.ajax({
      url: $(this).data('url'),
      type: 'PATCH',
      data: ajaxData
    })
  })
}

let postsTimePicker = () => {
  $('#post_published_at').daterangepicker({
    singleDatePicker: true,
    timePicker: true,
    timePicker24Hour: true,
    locale: {
      format: 'YYYY-MM-DD H:mm',
      applyLabel: "選択する",
      cancelLabel: "取消",
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
      ],
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
      ],
    },
  })
}


let initializeActivitiesWidget = () => {
  $.getScript('/activities_widget.js')
}

let fixHeightForTimelineWeekView = () => {
  let height = $('.fc-content').height();
  $('td.fc-resource-area.fc-widget-header > div.fc-scroller-clip').height(height);
  $('td.fc-time-area.fc-widget-header > div.fc-scroller-clip').height(height)
}



let filterAppointmentCategory = () => {
  $('#refresh-service-types').click(function(){
    $.getScript('/appointments_by_category_report/appointments?y=' + $('#query_year').val() + '&m=' + $('#query_month').val() + '&categories=' + $('#service_type_filter').val())
  })
}

let scrollAppointmentByCategory = () => {
  $('#see-more-service-category-data').click(function(){
    $container = $(this).parent('#category-subcontainer')
    $container.animate({ scrollTop: $container[0].clientHeight }, 500, 'swing')
  })
}

let newPostReminderLayout = () => {
  $('#show-reminder-form').click(function(){
    $(this).hide();
    $('#reminder-form').show();
  });
  $('#delete-reminder').click(function(){
    $('#reminder-form').hide();
    $('#form-reminder-anchor').val("");
    $('#show-reminder-form').show();
  });
  $('#delete-existing-reminder').click(function(){
    $('#reminder-form').hide()
  })

  $('#form-reminder-anchor').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      timePicker24Hour: true,
      timePickerIncrement: 15,
      startDate: moment().add(15, 'days'),
      locale: {
        format: 'YYYY-MM-DD',
        applyLabel: "選択する",
        cancelLabel: "取消",
        daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土"
        ],
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
        ],
        firstDay: 1
      }
    })
  })
}


let submitMerge = () => {
  $('#merge-submit').click(function(){
    var destination_service_id = $('#service_to_merge').val();
    if (destination_service_id) {
      var condition = confirm('サービスタイプが削除され、既存のサービスと実績が選択されたサービスへ統合されます')
      if (condition) {
        $(this).attr('href', function(i,h){
          return h + (h.indexOf('?') != -1 ? "&destination_service_id=" + destination_service_id : "?destination_service_id=" + destination_service_id)
        })
        return true
      } else {
        return false
      }
    } else {
      alert('統合先のサービスを選択してください')
      return false
    }
  })
}

let salaryRulesFormLayout = () => {
  bootstrapToggleForAllNursesCheckbox();
  toggleServiceTitleList();
}

let filterCmCorporations = () => {
  $('#cm_filter').change(function(){
    let selected_ids = $(this).val()
    if (selected_ids) {
      $('.cm_corporation').hide()
      selected_ids.forEach(function(id){
        $('#cm_corporation_' + id).show()
      })
    } else {
      $('.cm_corporation').show()
    }
  })
}

let filterCmTeikyohyo = () => {
  $('#cm_teikyohyo_filter').change(function(){
    let selected_ids = $(this).val()
    if (selected_ids) {
      $('.cm_teikyohyo').hide()
      selected_ids.forEach(function(id){
        $('#cm_teikyohyo_' + id).show()
      })
    } else {
      $('.cm_teikyohyo').show()
    }
  })
}

let showMonthlyWageField = () => {
  $('#full-timer-toggle').change(function(){
    nurseMonthlyWageField()
  })
}

let nurseMonthlyWageField = () => {
  if ($('#full-timer-toggle').is(':checked')) {
    $('#monthly_wage_group').show()
  } else {
    $('#monthly_wage_group').hide()
    $('#nurse_monthly_wage').val('')
  }
}



let bootstrapToggleForAllNursesCheckbox = () => {
  $('#all_nurses_selected_checkbox').bootstrapToggle({
    onstyle: 'info',
    offstyle: 'secondary',
    on: '全従業員対象',
    off: '従業員選択',
    size: 'small',
    width: 170
  })
}



let submitSmartSearch = () => {
  $('#submit-smart-search').click(function(){
    let skill_list = $('#nurse_skills_tags').val() || ''
    let wish_list = $('#nurse_wishes_tags').val() || ''
    let wished_area_list = $('#nurse_wished_areas_tags').val() || ''
    let url = $(this).data('url') + '?skill_list=' + skill_list + '&wish_list=' + wish_list + '&wished_area_list=' + wished_area_list
    $.getScript(url)
  })
}


let toggleServiceTitleList = () => {
  $('#all_services_selected_checkbox').on('change', function(){
    if ($('#all_services_selected_checkbox').is(':checked')) {
      $('#form_service_title_list_group').hide()
      $('#target-service-titles').val('')
    } else {
      $('#form_service_title_list_group').show()
    }
  })
}

let conditionallyShowCountBetweenAppointments = () => {
  $('#salary_rule_hour_based').change(function(){
    if ($(this).val() == 'true') {
      $('#only_count_between_appointments_checkbox').prop('checked', false)
      $('#only_count_between_appointments_group').hide()
    } else {
      $('#only_count_between_appointments_group').show()
    }
  })
}

let editSalaryRuleOnClick = () => {
  $('tr.salary_rule').click(function(){
    $.getScript($(this).data('url'))
  })
}

let confirmNoPatientOnSubmit = () => {
  $('#post_form').submit(function(){
    if (!$('#post_patient_id').val()) {
      confirmNoPatient = confirm('利用者タグなしでセーブされます')
      if (confirmNoPatient) {
        return true
      } else {
        return false
      }
    }
  })
}

let validateKatakana = () => {
  $('#patient_form').submit(function(){
    kana_validation = /^[0-9１-９ 　^[ァ-ヶー]*$/.test($('#patient_kana').val())
    if (kana_validation) {
      return true
    } else {
      alert('フリガナはカタカナで入力してください')
      return false 
    }
  })
}


let addSecondServiceCategory = () => {
  $('#add-second-service-type').click(function(){
    $('#second-service-type').show()
    $(this).hide()
  })
  $('#drop-second-service-category').click(function(){
    $('#service_category_ratio').val('')
    $('#service_category_2').val('')
    $('#second-service-type').hide()
    $('#add-second-service-type').show()
  })
}

let newBonusForm = () => {
  $('#bonus-provided-service-button').click(function () {
    $('.toggle-model-button').removeClass('btn-colibri-light-blue');
    $(this).addClass('btn-colibri-light-blue');
    $('#salary-rule-form-container').hide();
    $('#provided-service-form-container').show();
  });
  $('#bonus-salary-rule-button').click(function () {
    $('.toggle-model-button').removeClass('btn-colibri-light-blue');
    $(this).addClass('btn-colibri-light-blue');
    $('#salary-rule-form-container').show();
    $('#provided-service-form-container').hide();
  });
}


let toggleRecalculateCredits = () => {
  $('#service_recalculate_previous_credits_and_invoice').bootstrapToggle({
    on: '過去の実績に反映する',
    off: '反映なし',
    onstyle: 'info',
    offstyle: 'secondary',
    width: 220
  })
}

let reloadWhenDismissedInPayable = () => {
  $('.reload-page-when-dismissed-in-payable').click(function(){
    if (window.location.pathname.includes('payable')) {
      Turbolinks.reload()
    } else {
      $('.modal').modal('hide');
      $('.modal-backdrop').remove();
    }
  })
}

let insuranceScopeBootstrapToggle = () => {
  $('#service_inside_insurance_scope').bootstrapToggle({
    onstyle: 'info',
    offstyle: 'secondary',
    on: '保険内',
    off: '自費',
    width: 130
  })
}

let endOfContractDate = () => {
  $('#patient_end_of_contract').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      startDate: moment(),
      locale: {
        format: 'YYYY-MM-DD',
        applyLabel: "選択する",
        cancelLabel: "取消",
        daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土"
        ],
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
        ],
        firstDay: 1
      }
    })
  })
}

let handleAppointmentOverlapRevert = (revertFunc) => {
  $('#nurse-overlap-modal').on('shown.bs.modal', function () {
    $('#nurse-revert-overlap').one('click', function () {
      revertFunc()
    })
  })
}



let patientWarekiFields = () => {
  $('#care_plan_kaigo_certification_validity_start_era').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#care_plan_kaigo_certification_validity_start_year').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#care_plan_kaigo_certification_validity_start_month').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#care_plan_kaigo_certification_validity_start_day').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#care_plan_kaigo_certification_date_era').change(function(){
    set_kaigo_certification_date()
  })
  $('#care_plan_kaigo_certification_date_year').change(function(){
    set_kaigo_certification_date()
  })
  $('#care_plan_kaigo_certification_date_month').change(function(){
    set_kaigo_certification_date()
  })
  $('#care_plan_kaigo_certification_date_day').change(function(){
    set_kaigo_certification_date()
  })
  $('#care_plan_kaigo_certification_validity_end_era').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#care_plan_kaigo_certification_validity_end_year').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#care_plan_kaigo_certification_validity_end_month').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#care_plan_kaigo_certification_validity_end_day').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#patient_birthday_era').change(function(){
    set_birthday()
  })
  $('#patient_birthday_year').change(function(){
    set_birthday()
  })
  $('#patient_birthday_month').change(function(){
    set_birthday()
  })
  $('#patient_birthday_day').change(function(){
    set_birthday()
  })
}

let nurseWarekiFields = () => {
  $('#nurse_contract_date_era').change(function () {
    set_contract_date()
  })
  $('#nurse_contract_date_year').change(function () {
    set_contract_date()
  })
  $('#nurse_contract_date_month').change(function () {
    set_contract_date()
  })
  $('#nurse_contract_date_day').change(function () {
    set_contract_date()
  }) 
}

let set_contract_date = () => {
  let era = $('#nurse_contract_date_era').val() || ''
  let year = $('#nurse_contract_date_year').val() || ''
  let month = $('#nurse_contract_date_month').val() || ''
  let day = $('#nurse_contract_date_day').val() || ''
  if (year.length === 1) {
    year = `0${year}`
  }
  if (month.length === 1) {
    month = `0${month}`
  }
  if (day.length === 1) {
    day = `0${day}`
  }
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#nurse_contract_date').val(wareki_date)
}

let set_kaigo_certification_validity_end = () => {
  let era = $('#care_plan_kaigo_certification_validity_end_era').val() || ''
  let year = $('#care_plan_kaigo_certification_validity_end_year').val() || ''
  let month = $('#care_plan_kaigo_certification_validity_end_month').val() || ''
  let day = $('#care_plan_kaigo_certification_validity_end_day').val() || ''
  if (year.length === 1) {
    year = `0${year}`
  }
  if (month.length === 1) {
    month = `0${month}`
  }
  if (day.length === 1) {
    day = `0${day}`
  }
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#care_plan_kaigo_certification_validity_end').val(wareki_date)
}

let set_kaigo_certification_validity_start = () => {
  let era = $('#care_plan_kaigo_certification_validity_start_era').val() || ''
  let year = $('#care_plan_kaigo_certification_validity_start_year').val() || ''
  let month = $('#care_plan_kaigo_certification_validity_start_month').val() || ''
  let day = $('#care_plan_kaigo_certification_validity_start_day').val() || ''
  if (year.length === 1) {
    year = `0${year}`
  }
  if (month.length === 1) {
    month = `0${month}`
  }
  if (day.length === 1) {
    day = `0${day}`
  }
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#care_plan_kaigo_certification_validity_start').val(wareki_date)
}

let set_kaigo_certification_date = () => {
  let era = $('#care_plan_kaigo_certification_date_era').val() || ''
  let year = $('#care_plan_kaigo_certification_date_year').val() || ''
  let month = $('#care_plan_kaigo_certification_date_month').val() || ''
  let day = $('#care_plan_kaigo_certification_date_day').val() || ''
  if (year.length === 1) {
    year = `0${year}`
  }
  if (month.length === 1) {
    month = `0${month}`
  }
  if (day.length === 1) {
    day = `0${day}`
  }
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#care_plan_kaigo_certification_date').val(wareki_date)
}

let set_birthday = () => {
  let era = $('#patient_birthday_era').val() || ''
  let year = $('#patient_birthday_year').val() || ''
  let month = $('#patient_birthday_month').val() || ''
  let day = $('#patient_birthday_day').val() || ''
  if (year.length === 1) {
    year = `0${year}`
  }
  if (month.length === 1) {
    month = `0${month}`
  }
  if (day.length === 1) {
    day = `0${day}`
  }
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#patient_birthday').val(wareki_date)
}



let adaptServiceInvoiceFields = () => {
  $('#service_inside_insurance_scope').change(function(){
    if ($(this).is(':checked')) {
      $('#insurance_category_2_group').show()
      $('#fields_for_kaigo_invoicing').show()
      $('#insurance_service_category').val('')
      $('#service_invoiced_amount').val('')
      $('#fields_for_invoicing_without_insurance').hide()
    } else {
      $('#insurance_category_2_group').hide()
      $('#service_official_title').val('')
      $('#service_service_code').val('')
      $('#service_unit_credits').val('')
      $('#fields_for_kaigo_invoicing').hide()
      $('#fields_for_invoicing_without_insurance').show()
    }
  })
}

let warekiHelper = () => {
  $('.wareki_era').change(function(){
    $(this).next('.wareki_year').focus()
  })
  let valid_years = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64"]
  let valid_months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
  let valid_days = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
  $('.wareki_year').on('input', function(){
    if ($(this).val().length > 1) {
      if (valid_years.includes($(this).val())) {
        $(this).next('.wareki_month').focus()
      } else {
        alert('年が間違ってます')
        $(this).val('')
      }
    }
  })
  $('.wareki_month').on('input', function(){
    if ($(this).val().length > 1) {
      if (valid_months.includes($(this).val())) {
        $(this).next('.wareki_day').focus()
      } else {
        alert('月が間違ってます')
        $(this).val('')
      }
    }
  })
  $('.wareki_day').on('input' ,function(){
    if ($(this).val().length > 1) {
      if (valid_days.includes($(this).val())) {
      } else {
        alert('日が間違ってます')
        $(this).val('')
      }
    }
  })
}

let availabilitiesDate = () => {
  $('#availabilities_date').daterangepicker({
    singleDatePicker: true,
    locale: {
      format: 'YYYY-MM-DD',
      daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土",
      ],
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
      ],
      firstDay: 1
    }
  })
}

$(document).on('turbolinks:load', function(){

  $('#completion_reports_query_date').daterangepicker({
    singleDatePicker: true,
    locale: {
      format: 'YYYY-MM-DD',
      daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土",
      ],
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
      ],
      firstDay: 1
    }
  })

  $('#completion_reports_query_date').change(function(){
    var url = completionReportsSummaryUrl + '?reports_date=' + $(this).val()
    window.location = url
  })

  $('#date-picker-button').click(function(){
    $('#completion_reports_query_date').click()
  })

  $(window).resize(function(){
    if (window.fullCalendar) {
      if (!window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches && !window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
        window.fullCalendar.setOption('height', (window.innerHeight - 160))
      }
    }
  })
  
  $('.resource-details-button').click(function(){
    let url = document.getElementById('resource-details-button').dataset.resourceUrl 
    $.getScript(url)
    
    if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
      $('#colibri-batch-action-button').hide()
    }
  })

  $('#sort-posts-by-patient-tag').click(function(){
    let range_start 
    let range_end
    if ($('#posts_date_range').data('daterangepicker')) {
      range_start = $('#posts_date_range').data('daterangepicker').startDate.format('YYYY-MM-DD H:mm')
      range_end = $('#posts_date_range').data('daterangepicker').endDate.format('YYYY-MM-DD H:mm')
    }

    let queryData = {
      range_start: range_start,
      range_end: range_end,
      patient_ids: $('#posts_patient_ids_filter').val(),
      author_ids: $('#posts_author_ids_filter').val(),
      order_by_patient: true
    }
    $.ajax({
      url: '/posts.js',
      data: queryData
    })
  })


  $('#toggle-switch-recurring-appointments').click(function(){
    $(this).hide()
    $('#toggle-switch-wished-slots').show()
    window.selectActionUrl = window.createWishedSlotUrl
    window.eventsUrl1 = window.wishedSlotsUrl
    window.eventsUrl2 = ''
    if (window.fullCalendar) {
      window.fullCalendar.refetchEvents()
    }
  })

  $('#toggle-switch-wished-slots').click(function(){
    $(this).hide()
    $('#toggle-switch-recurring-appointments').show()
    window.eventsUrl1 = window.recurringAppointmentsUrl
    window.eventsUrl2 = window.wishedSlotsUrl + '?background=true'
    window.selectActionUrl = window.createRecurringAppointmentURL
    if (window.fullCalendar) {
      window.fullCalendar.refetchEvents()
    }
  })

  $('#availabilities-print').click(function(){
    $('#availabilities-form').modal()
    availabilitiesDate()
  })

  $('#confirm-availabilities-print').click(function(){
    date = $('#availabilities_date').val()
    text = $('#availabilities_text').val().replace(/\n/g, '<br />')
    if (date) {
      window.open($(this).data('link') + '?date=' + date + '&text=' + text, '_blank')
    } else {
      alert('期間を選択してください')
    }
  })

  if ($('#activities-widget-container').length > 0) {
    initializeActivitiesWidget()
  }

  $('#colibri-batch-action-button').popover({
    html: true,
    title: '',
    content: $('#batch-action-menu').html(),
    trigger: 'click',
    placement: 'top'
  })
  
  $('body').on('click', '#print-button', function(){
    if (window.fullCalendar && window.fullCalendar.view && (window.fullCalendar.view.type === 'dayGridMonth')) {
      window.fullCalendar.setOption('aspectRatio', 1.4)
      window.fullCalendar.setOption('height', 'auto')
    }
    if (!window.printDates) {
      $('.fc-day-header.fc-mon').html('月')
      $('.fc-day-header.fc-tue').html('火')
      $('.fc-day-header.fc-wed').html('水')
      $('.fc-day-header.fc-thu').html('木')
      $('.fc-day-header.fc-fri').html('金')
      $('.fc-day-header.fc-sat').html('土')
      $('.fc-day-header.fc-sun').html('日')
    }
    window.print()
    $('#colibri-batch-action-button').click()
  })
  
  $('body').on('click', 'span#new-reminder-email', function(){
    let nurseResource = (window.currentResourceType === 'nurse' && window.currentResourceId !== 'all') || (!window.currentResourceType && window.defaultResourceType === 'nurse' && window.defaultResourceId !== 'all')
    if (nurseResource) {
      $.getScript(`/nurses/${window.currentResourceId || window.defaultResourceId}/new_reminder_email`)
    }
  })
  
  $('body').on('click', 'span#colibri-master-action-button', function(){
    let individualResource = (window.currentResourceType && window.currentResourceId !== 'all') || (!window.currentResourceType && window.defaultResourceId !== 'all')
    if (individualResource) {
      $.getScript(`/${window.currentResourceType || window.defaultResourceType}s/${window.currentResourceId || window.defaultResourceId}/new_master_to_schedule`)
    } else {
      if (window.corporationHasTeams) {
        alert('反映はチーム別、または従業員別で行ってください。')
      } else {
        $.getScript(`${window.planningPath}/new_master_to_schedule`)
      }
    }
  })

  $.fn.modal.Constructor.prototype._enforceFocus = function () { };

  $('#account-settings').click(function(){
    $('#account-settings-dropdown').toggle();
  });

  $('li.account-settings-li').click(function(){
    window.location = $(this).data('url');
  });

  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove(); 
      });
  }, 2500);

  $('.colibri-nav-username').hover(function(){
    $('#account-dropdown-icon').css({'color':'black', 'cursor':'pointer'})
  }, function(){
    $('#account-dropdown-icon').css({'color': 'white'})
  })

  $('#header-calendar-button').click(function(){
    $('#resource-details-wrapper').remove()
    $('#calendar').show()
    window.fullCalendar.render()
    window.scrollTo(0,0)
    $('#colibri-batch-action-button').show()
  })

  $('.reports-index-button').click(function () {
    var data = {};
    data['resource_type'] = window.currentResourceType || window.defaultResourceType

    if (data['resource_type'] === 'team') {
      return
    }

    if (window.currentResourceType === 'nurse' || (!window.currentResourceType && window.defaultResourceType === 'nurse')) {
      data['nurse_id'] = window.currentResourceId || window.defaultResourceId
    } else if (window.currentResourceType === 'patient' || (!window.currentResourceType && window.defaultResourceType === 'patient')) {
      data['patient_id'] = window.currentResourceId || window.defaultResourceId
    }

    if (data['nurse_id'] === 'all' || data['patient_id'] === 'all') {
      return
    }

    data['m'] = window.currentMonth
    data['y'] = window.currentYear

    $.ajax({
      type: 'GET',
      url: '/completion_reports.js',
      data: data
    })

    if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
      $('#colibri-batch-action-button').hide()
    }
  })

  $('.resource-title-selectable, .resource-list-element').click(function(){
    $('#colibri-batch-action-button').popover('hide')
    if (['team', 'patient'].includes($(this).data('resource-type')) || $(this).data('resource-id') === 'all') {
      $('#new-reminder-email').empty()
      $('#colibri-batch-action-button').popover('dispose')
      $('#colibri-batch-action-button').popover({
        html: true,
        title: '',
        content: $('#batch-action-menu').html(),
        trigger: 'click',
        placement: 'top'
      })
    } else {
      $('#colibri-batch-action-button').popover('dispose')
      $('#new-reminder-email').html($('#reminder-container').html())
      $('#colibri-batch-action-button').popover({
        html: true,
        title: '',
        content: $('#batch-action-menu').html(),
        trigger: 'click',
        placement: 'top'
      })

    }
  })

  $('#cancelled-report-button').click(function(){
    $('#cancelled_reports_modal').modal('show')
    $('#cancelled_reports_query_range').focus(function(){
      $(this).daterangepicker({
        locale: {
          format: 'M月D日',
          applyLabel: "選択する",
          cancelLabel: "取消",
          daysOfWeek: [
            "日",
            "月",
            "火",
            "水",
            "木",
            "金",
            "土"
          ],
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
          ],
          firstDay: 1
        }
      })
    })
  })

  $('#submit-cancelled-report').click(function(){
    let range_start 
    let range_end
    if ($('#cancelled_reports_query_range').data('daterangepicker')) {
      range_start = $('#cancelled_reports_query_range').data('daterangepicker').startDate.format('YYYY-MM-DD')
      range_end = $('#cancelled_reports_query_range').data('daterangepicker').endDate.format('YYYY-MM-DD')
    }

    let url = $(this).data('url') + '?range_start=' + range_start + '&range_end=' + range_end;

    window.location = url
  })

  $('#extended-daily-report').click(function(){
    $('#extended-daily-summary-modal').modal('show')
    $('#extended_report_date').daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      minYear: 2016,
      maxYear: 2030,
      locale: {
        format: 'YYYY-MM-DD',
        daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土"
        ],
        monthNames: [
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8",
          "9",
          "10",
          "11",
          "12",
        ],
        firstDay: 1
      }
    })
  })



  if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
    $('#payable-menu').click(function(){
      $('#resource-list-container').show()
      $('#menu-backdrop').show()
    })
    
    $('.resource-list-element, .resource-title-selectable').click(function(){
      if (!$(this).hasClass('nurse-subsection-toggleable')) {
        $('#resource-list-container').hide()
        $('#menu-backdrop').hide()
      }
    })

    $('#menu-backdrop').click(function(){
      $(this).hide()
      $('#resource-list-container').hide()
      $('#settings-menu-container').hide()
    })
    
    $('#close-resource').click(function(){
      $('#resource-list-container').hide()
      $('#menu-backdrop').hide()
    })
    
    $('#payable-menu').click(function(){
      $('#settings-menu-container').show()
      $('#resource-list-container').show()
      $('#menu-backdrop').show()
    })
    
    $('#settings-menu').click(function(){
      $('#settings-menu-container').show()
      $('#menu-backdrop').show()
    })
    
    $('#close-settings').click(function(){
      $('#settings-menu-container').hide()
      $('#menu-backdrop').hide()
    })

    $('.header-submenu-item').click(function () {
      $('#colibri-batch-action-button').popover('hide')
      $('.header-submenu-item').removeClass('header-submenu-item-selected')
      $(this).addClass('header-submenu-item-selected')
    })
  }
}); 

