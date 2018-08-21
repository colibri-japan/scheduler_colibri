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
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require moment.min
//= require chosen.jquery
//= require popper
//= require bootstrap
//= require bootstrap-toggle
//= require fullcalendar
//= require locale-all
//= require scheduler
//= require daterangepicker
//= require_tree .

var adjustCalendar;
adjustCalendar = function(){
  $('td.fc-head-container').css({'padding-right': '16px'});
  $('.fc-day-grid').css({'padding-right': '16px'});
};



var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  
  $('.nurse_calendar').each(function(){
    loadNurseRecurringAppointments();
    var nurse_calendar = $(this);
    nurse_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      locale: 'ja',
      views: {
        agendaThreeDay: {
          type: 'agenda',
          duration: {days: 3},
          buttonText: '３日'
        }
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: true,
      selectHelper: false,
      eventStartEditable: false,
      editable: true,
      eventLimit: true,
      eventColor: '#7AD5DE',
      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL + '?nurse_id=' + window.nurseId],


      select: function(start, end) {
        $.getScript(window.createRecurringAppointmentURL, function() {
          $('.master-toggle').bootstrapToggle({
             on: 'マスター',
             off: '普通',
             size: 'normal',
             onstyle: 'success',
             offstyle: 'info',
             width: 100,
          });
          $('#form-save-decoy').click(function(){
            if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
              alert('ヘルパーが未定です。');
            } else if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              if ($('#recurring_appointment_master').is(":checked")) {
                var message = confirm("このサービスはマスターとしてセーブされます。");
                if (message) {
                  $('#form-save').click();
                } else {
                  return false;
                }
              } else {
                $('#form-save').click();
              } 
            }
          });


          $('#form-edit-list-decoy').click(function(){
            if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              var message = confirm("このサービスは編集リストへ追加されます。");
              if (message) {
                $('#form-edit-list').click();
              }
            }
          });

        	$('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
        	$('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
        	$('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
          $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
          $('#recurring_appointment_end_day_3i').val(moment(end).format('D')); 
        	$('#recurring_appointment_start_4i').val(moment(start).format('HH'));
        	$('#recurring_appointment_start_5i').val(moment(start).format('mm'));
        	$('#recurring_appointment_end_4i').val(moment(end).format('HH'));
        	$('#recurring_appointment_end_5i').val(moment(end).format('mm'));
        	$("#recurring_appointment_nurse_id").val(window.nurseId);
        });

        nurse_calendar.fullCalendar('unselect');
      },

      eventRender: function(event, element, view){
        element.find('.fc-title').text(function(i, t){
          return event.patient_name;
        });
        return event.displayable;
      },
         
      eventClick: function(event, jsEvent, view) {
        if (event.editable === true) {
          $.getScript(event.edit_url, function() {
            $('.master-toggle').bootstrapToggle({
               on: 'マスター',
               off: '普通',
               size: 'normal',
               onstyle: 'success',
               offstyle: 'info',
               width: 100,
            });

            $('#form-delete').click(function(){
              var deletedDays = $('#recurring_appointment_edited_occurrence').val();
              var message = confirm('選択された繰り返しが削除されます：' + deletedDays);
              if (message) {
                destroy_data = {
                  recurring_appointment: {
                    edited_occurrence: deletedDays,
                    master: $('#recurring_appointment_master').is(":checked"),
                  }
                }
                $.ajax({
                  url: appointment.base_url + '.js',
                  type: 'DELETE',
                  data: destroy_data,
                  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                })
              }
            });

            $('#form-save-decoy').click(function(){
              if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
                alert('ヘルパーが未定です。');
              } else if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else {
                if ($('#recurring_appointment_master').is(":checked")) {
                  var message = confirm("このサービスはマスターとしてセーブされます。");
                  if (message) {
                    $('#form-save').click();
                  } else {
                    return false;
                  }
                } else {
                  $('#form-save').click();
                }
              }

            });


            $('#form-edit-list-decoy').click(function(){
              if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else {
                var editRequested = $('#recurring_appointment_edited_occurrence').val();
                var message = confirm('選択された繰り返しが編集リストへ追加されます：' + editRequested);
                if (message) {
                  $('#form-edit-list').click();
                } else {
                  return false;
                }
              }

            });
          });
        }

      }



    })
  })
}


var initialize_patient_calendar;
initialize_patient_calendar = function(){
  
  $('.patient_calendar').each(function(){
    loadPatientRecurringAppointments();
    var patient_calendar = $(this);
    patient_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      minTime: window.minTime,
      maxTime: window.maxTime, 
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      locale: 'ja',
      eventColor: '#7AD5DE',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      selectable: true,
      selectHelper: false,
      editable: true,
      eventLimit: true,
      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL + '?patient_id=' + window.patientId, window.unavailabilitiesUrl + '?patient_id=' + window.patientId],


      select: function(start, end) {
        $.getScript(window.bootstrapToggleUrl, function() {
          $('.master-toggle').bootstrapToggle({
             on: 'マスター',
             off: '普通',
             size: 'normal',
             onstyle: 'success',
             offstyle: 'info',
             width: 100,
          });
          $('#form-save-decoy').click(function(){
            if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
              alert('ヘルパーが未定です。');
            } else if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              if ($('#recurring_appointment_master').is(":checked")) {
                var message = confirm("このサービスはマスターとしてセーブされます。");
                if (message) {
                  $('#form-save').click();
                } else {
                  return false;
                }
              } else {
                $('#form-save').click();
              } 
            }
          });


          $('#form-edit-list-decoy').click(function(){
            if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              var message = confirm("このサービスは編集リストへ追加されます。");
              if (message) {
                $('#form-edit-list').click();
              }
            }
          });

          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));        	
          $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
          $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
          $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));          
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          $("#recurring_appointment_patient_id").val(window.patientId);
          $('#unavailability_start_1i').val(moment(start).format('YYYY'));
          $('#unavailability_start_2i').val(moment(start).format('M'));
          $('#unavailability_start_3i').val(moment(start).format('D'));
          $('#unavailability_start_4i').val(moment(start).format('HH'));
          $('#unavailability_start_5i').val(moment(start).format('mm'));
          $('#unavailability_end_1i').val(moment(end).format('YYYY'));
          $('#unavailability_end_2i').val(moment(end).format('M'));
          $('#unavailability_end_3i').val(moment(end).format('D'));
          $('#unavailability_end_4i').val(moment(end).format('HH'));
          $('#unavailability_end_5i').val(moment(end).format('mm'));
          $("#unavailability_patient_id").val(window.patientId);
        });


        nurse_calendar.fullCalendar('unselect');
      },

      eventRender: function(appointment, element, view){
        element.find('.fc-title').text(function(i, t){
          return appointment.nurse_name;
        });
        return appointment.displayable;
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format(),
             }
           };
           $.ajax({
               url: appointment.base_url + '.js?delta=' + delta,
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
           $.getScript(appointment.edit_url, function() {
            $('.master-toggle').bootstrapToggle({
               on: 'マスター',
               off: '普通',
               size: 'normal',
               onstyle: 'success',
               offstyle: 'info',
               width: 100,
            });

            $('#form-delete').click(function(){
              var deletedDays = $('#recurring_appointment_edited_occurrence').val();
              var message = confirm('選択された繰り返しが削除されます：' + deletedDays);
              if (message) {
                destroy_data = {
                  recurring_appointment: {
                    edited_occurrence: deletedDays,
                    master: $('#recurring_appointment_master').is(":checked"),
                  }
                }
                $.ajax({
                  url: appointment.base_url + '.js',
                  type: 'DELETE',
                  data: destroy_data,
                  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                })
              }
            });

            $('#form-save-decoy').click(function(){
              if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
                alert('ヘルパーが未定です。');
              } else if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else {
                if ($('#recurring_appointment_master').is(":checked")) {
                  var message = confirm("このサービスはマスターとしてセーブされます。");
                  if (message) {
                    $('#form-save').click();
                  } else {
                    return false;
                  }
                } else {
                  $('#form-save').click();
                }
              }

            });


            $('#form-edit-list-decoy').click(function(){
              if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else {
                var editRequested = $('#recurring_appointment_edited_occurrence').val();
                var message = confirm('選択された繰り返しが編集リストへ追加されます：' + editRequested);
                if (message) {
                  $('#form-edit-list').click();
                } else {
                  return false;
                }
              }


            });
           });
         }

    });
  })
};

var initialize_master_calendar;
initialize_master_calendar = function() {
  synchronizeMasterTitle();
  loadMasterAppointmentDetails();
  $('.master-calendar').each(function(){
    var master_calendar = $(this);
    master_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      views: {
      	agendaThreeDay: {
      		type: 'agenda',
      		duration: {days: 3},
      		buttonText: '３日'
      	}
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: (window.userIsAdmin == 'true') ? true : false,
      selectHelper: false,
      editable: (window.userIsAdmin == 'true') ? true : false,
      eventLimit: true,
      eventColor: '#7AD5DE',


      resources: {
        url: window.corporationNursesURL,
      }, 

      eventSources: [ window.appointmentsURL + '?q=master', window.recurringAppointmentsURL + '?q=master'],

      eventRender: function eventRender(event, element, view) {
      	element.find('.fc-title').text(function(i,t){
      		if ($('#toggle-patients-nurses').is(':checked')) {
      			return event.nurse_name;
      		} else {
      			return event.patient_name;
      		}
      	});
        var selectedName = $('.master-element-selected').text() ;
        var filterName;
        filterName = function(){
          if (selectedName == event.nurse_name || selectedName == event.patient_name) {
            return true;
          } else {
            return false;
          }
        }

        return filterName() && !event.editRequested && event.master ;
      },


      select: function(start, end, jsEvent, view, resource) {
        $.getScript(window.createRecurringAppointmentURL + '?q=master', function() {
          $('.master-toggle').bootstrapToggle({
             on: 'マスター',
             off: '普通',
             size: 'normal',
             onstyle: 'success',
             offstyle: 'info',
             width: 100,
          });
          $('#form-save-decoy').click(function(){
            if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
              alert('ヘルパーが未定です。');
            } else if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              if ($('#recurring_appointment_master').is(":checked")) {
                var message = confirm("このサービスはマスターとしてセーブされます。");
                if (message) {
                  $('#form-save').click();
                } else {
                  return false;
                }
              } else {
                $('#form-save').click();
              } 
            }
          });


          $('#form-edit-list-decoy').click(function(){
            if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              var message = confirm("このサービスは編集リストへ追加されます。");
              if (message) {
                $('#form-edit-list').click();
              }
            }
          });

          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
          $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
          $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          if (view.name == 'agendaDay') {
            $('#recurring_appointment_nurse_id').val(resource.id);
          }
        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format()
             }
           };
           $.ajax({
               url: appointment.base_url + '.js?q=master',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
            if (window.userIsAdmin == 'true') {
              $.getScript(appointment.edit_url + '?q=master', function() {
                $('.master-toggle').bootstrapToggle({
                   on: 'マスター',
                   off: '普通',
                   size: 'normal',
                   onstyle: 'success',
                   offstyle: 'info',
                   width: 100,
                 });

                $('#form-delete').click(function(){
                  var deletedDays = $('#recurring_appointment_edited_occurrence').val();
                  var message = confirm('選択された繰り返しがマスターから削除されます：' + deletedDays);
                  if (message) {
                    destroy_data = {
                      recurring_appointment: {
                        edited_occurrence: deletedDays,
                        master: $('#recurring_appointment_master').is(":checked"),
                      }
                    }
                    $.ajax({
                      url: appointment.base_url + '.js',
                      type: 'DELETE',
                      data: destroy_data,
                      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                    })
                  }
                });

                $('#form-save-decoy').click(function(){
                  if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
                    alert('ヘルパーが未定です。');
                  } else if ($('#recurring_appointment_title').val() == "") {
                    alert('サービスタイプを入力してください');
                  } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                    alert('利用者を選択してください');
                  } else {
                    if ($('#recurring_appointment_master').is(":checked")) {
                      var message = confirm("このサービスはマスターとしてセーブされます。");
                      if (message) {
                        $('#form-save').click();
                      } else {
                        return false;
                      }
                    } else {
                      $('#form-save').click();
                    }
                  }

                });


                $('#form-edit-list-decoy').click(function(){
                  if ($('#recurring_appointment_title').val() == "") {
                    alert('サービスタイプを入力してください');
                  } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                    alert('利用者を選択してください');
                  } else {
                    var editRequested = $('#recurring_appointment_edited_occurrence').val();
                    var message = confirm('選択された繰り返しが編集リストへ追加されます：' + editRequested);
                    if (message) {
                      $('#form-edit-list').click();
                    } else {
                      return false;
                    }
                  }

                });
              });
            }
            return false;
         }
    })
    
  });
};

var initialize_calendar;
initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      views: {
      	agendaThreeDay: {
      		type: 'agenda',
      		duration: {days: 3},
      		buttonText: '３日',
      	},
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      height: 'auto',
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: true,
      selectHelper: false,
      editable: true,
      eventLimit: true,
      eventColor: '#7AD5DE',


      resources: {
        url: window.corporationNursesURL,
      }, 

      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL, window.unavailabilitiesUrl],

      eventRender: function eventRender(event, element, view) {
        if (view.name == 'agendaDay') {
          element.find('.fc-title').text(function(i, t){
            return event.patient_name;
          });
        }


        var patientFilterArray = $('#patient-filter-zentai_').val();
        var nurseFilterArray = $('#nurse-filter-zentai_').val();
        var editRequestFilter = $('#edit-request-filter').prop('checked');
        if (patientFilterArray === null) {
          patientFilterArray = ['']
        };

        if (nurseFilterArray === null) {
          nurseFilterArray = ['']
        };

        var filterPatient = function(){
          for (var i=0; i < patientFilterArray.length; i++) {
            if (['', event.patientId.toString()].indexOf(patientFilterArray[i]) >= 0) {
              return true
            }
          }
          return false
        }
        var filterNurse = function() {
          for (var i=0; i< nurseFilterArray.length; i++) {
            if (['', event.resourceId].indexOf(nurseFilterArray[i]) >= 0) {
              return true
            }
          }
          return false
        } 
        var filterEditRequested = function(){
          if (editRequestFilter == false) {
            return event.editRequested;
          } else {
            return true;
          }
        }

        return filterPatient() && filterNurse() && filterEditRequested() ;
      },

      viewRender: function(view, element){
        adjustCalendar();
      },


      select: function(start, end, jsEvent, view, resource) {
      	$.getScript(window.bootstrapToggleUrl, function() {
          $('.master-toggle').bootstrapToggle({
             on: 'マスター',
             off: '普通',
             size: 'normal',
             onstyle: 'success',
             offstyle: 'info',
             width: 100,
          });
          $('#form-save-decoy').click(function(){
            if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
              alert('ヘルパーが未定です。');
            } else if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else {
              if ($('#recurring_appointment_master').is(":checked")) {
                var message = confirm("このサービスはマスターとしてセーブされます。");
                if (message) {
                  $('#form-save').click();
                } else {
                  return false;
                }
              } else {
                $('#form-save').click();
              } 
            }
          });


          $('#form-edit-list-decoy').click(function(){
            if ($('#recurring_appointment_title').val() == "") {
              alert('サービスタイプを入力してください');
            } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
              alert('利用者を選択してください');
            } else if ($('#recurring_appointment_master').is(":checked")) {
              alert('編集リストへ追加されるサービスはマスターとして登録できません。')
            } else {
              var message = confirm("このサービスは編集リストへ追加されます。");
              if (message) {
                $('#form-edit-list').click();
              }
            }
          });



          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
          $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
          $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          $('#unavailability_start_1i').val(moment(start).format('YYYY'));
          $('#unavailability_start_2i').val(moment(start).format('M'));
          $('#unavailability_start_3i').val(moment(start).format('D'));
          $('#unavailability_start_4i').val(moment(start).format('HH'));
          $('#unavailability_start_5i').val(moment(start).format('mm'));
          $('#unavailability_end_1i').val(moment(end).format('YYYY'));
          $('#unavailability_end_2i').val(moment(end).format('M'));
          $('#unavailability_end_3i').val(moment(end).format('D'));
          $('#unavailability_end_4i').val(moment(end).format('HH'));
          $('#unavailability_end_5i').val(moment(end).format('mm'));
          if (view.name == 'agendaDay') {
            $('#recurring_appointment_nurse_id').val(resource.id);
          }

        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format(),
               nurse_id: appointment.resourceId
             }
           };
           $.ajax({
               url: appointment.base_url + '.js',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
           $.getScript(appointment.edit_url + '?view_start=' + moment(view.intervalStart).format('YYYY-MM-DD') + '&view_end=' + moment(view.intervalEnd).format('YYYY-MM-DD') , function() {
           	$('.master-toggle').bootstrapToggle({
              on: 'マスター',
              off: '普通',
              size: 'normal',
              onstyle: 'success',
              offstyle: 'info',
              width: 100,
            });

            $('#form-delete').click(function(){
              var deletedDays = $('#recurring_appointment_edited_occurrence').val();
              var message = $('#recurring_appointment_master').is(":checked") == true ? confirm('選択された繰り返しがマスターを含めて削除されます：' + deletedDays) : confirm('選択された繰り返しが削除されます：' + deletedDays);
              if (message) {
                destroy_data = {
                  recurring_appointment: {
                    edited_occurrence: deletedDays,
                    master: $('#recurring_appointment_master').is(":checked"),
                  }
                }
                $.ajax({
                  url: appointment.base_url + '.js',
                  type: 'DELETE',
                  data: destroy_data,
                  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                })
              }
            });

            $('#form-save-decoy').click(function(){
              if ($('#recurring_appointment_nurse_id').find('option:selected').text() == '未定') {
                alert('ヘルパーが未定です。');
              } else if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else {
                if ($('#recurring_appointment_master').is(":checked")) {
                  var message = confirm("このサービスはマスターとしてセーブされます。");
                  if (message) {
                    $('#form-save').click();
                  } else {
                    return false;
                  }
                } else {
                  $('#form-save').click();
                }
              }

            });


            $('#form-edit-list-decoy').click(function(){
              if ($('#recurring_appointment_title').val() == "") {
                alert('サービスタイプを入力してください');
              } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
                alert('利用者を選択してください');
              } else if ($('#recurring_appointment_master').is(":checked")) {
                alert('編集リストへ追加されるサービスはマスターとして登録できません。')
              } else {
                var editRequested = $('#recurring_appointment_edited_occurrence').val();
                var message = confirm('選択された繰り返しが編集リストへ追加されます：' + editRequested);
                if (message) {
                  $('#form-edit-list').click();
                } else {
                  return false;
                }
              }
            });



           });

         }


    });
  });
};

var loadPatientRecurringAppointments;
loadPatientRecurringAppointments = function(){
  $.ajax({
    url: window.recurringAppointmentsURL + '.js?patient_id=' + window.patientId + '&print=true',
    type: 'GET',
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
  });
  return true;
};

var loadNurseRecurringAppointments;
loadNurseRecurringAppointments = function(){
  $.ajax({
    url: window.recurringAppointmentsURL + '.js?nurse_id=' + window.nurseId + '&print=true',
    type: 'GET',
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
  });
  return true;
}

var loadMasterAppointmentDetails;
loadMasterAppointmentDetails = function(){
  var targetName = $('.master-element-selected').text();
  var targetType = $('#toggle-patients-nurses').is(':checked') ? 'patient_name=' : 'nurse_name=';
  if (window.recurringAppointmentsURL) {
    $.ajax({
      url: window.recurringAppointmentsURL + '.js?' + targetType + targetName + '&print=true',
      type: 'GET',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    });
    return true;
  }

}

var synchronizeMasterTitle;
synchronizeMasterTitle = function(){
  $('.master-title').text(function(){
    return $('.master-element-selected').text();
  });
}

var synchronizeMasterAddressAndPhone;
synchronizeMasterAddressAndPhone = function(){
  $('#master-address').text(function(){
    return $('.master-element-selected').data('address');
  });
  $('#master-phone').text(function(){
    return $('.master-element-selected').data('phone');
  })
}

$(document).on('turbolinks:load', initialize_calendar); 
$(document).on('turbolinks:load', initialize_nurse_calendar); 
$(document).on('turbolinks:load', initialize_patient_calendar); 
$(document).on('turbolinks:load', initialize_master_calendar);

$(document).on('turbolinks:load', function(){
  $("table > tbody > tr[data-link]").not('thead').click(function(){
    if (this.dataset.link != '') {
      window.location = this.dataset.link
    } 
  });

  $('#account-edit').click(function(){
    $('#account-delete-body').hide();
    $('#account-edit-body').show();
    $('.account-menu-item').removeClass('account-menu-selected');
    $(this).addClass('account-menu-selected');
  });

  $('#account-delete').click(function(){
    $('#account-edit-body').hide();
    $('#account-delete-body').show();
    $('.account-menu-item').removeClass('account-menu-selected');
    $(this).addClass('account-menu-selected');
  });

  $('#account-delete-body').hide();

  $('.switch').each(function(){
    $this = $(this);
    if ($this.data('admin') == true ) {
      $this.find('.switch-input').prop("checked", true);
    }

  });

  $('.slider').bind('sendAjax', function(){
    $.ajax({
      url: $(this).data('admin-toggle'),
      type: 'PATCH',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    })
  })

  $('.slider').click(function(){
    $(this).trigger('sendAjax');

  });

  $('input.edit-hourly-wage').change(function(){
    $.ajax({
      url: $(this).data('service-url') + '.js',
      type: 'PATCH',
      data:  { 'provided_service': { 'hourly_wage': $(this).val() }  },
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    })
  });

  $('input.edit-service-counts').change(function(){
    $.ajax({
      url: $(this).data('service-url') + '.js',
      type: 'PATCH',
      data: {'provided_service': {'service_counts': $(this).val()}},
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))}
    })
  });

  $('#schedule-filter').change(function(){
    window.location = nursePayableUrl + '?p=' + $(this).val();
  });

  $('#activity-filter').change(function(){
    window.location = planningActivitiesUrl + '?n=' + $('#nurse-filter').val() + '&pat=' + $('#patient-filter').val() + '&us=' + $('#user-filter').val();
  });

  $('.excel-download').click(function(){
    window.location = window.excelUrl + '?p=' + $('#schedule-filter').val();
  });

  $('li.planning-menu-items').click(function(){
    window.location = $(this).data('url');
  })

  $('#planning-activity-module').hide();
  $('#activity-hide-button').hide();

  $('#activity-show-button').click(function(){
    $('#planning-activity-module').show();
    $('.calendar').css({'max-width': '75%'});
    $('.nurse_calendar').css({'max-width': '75%'});
    $('.patient_calendar').css({'max-width': '75%'});
    $(this).hide();
    $('#activity-hide-button').show();
  });

  $('#activity-hide-button').click(function(){
    $(this).hide();
    $('.calendar').css({'max-width': ''});
    $('.nurse_calendar').css({'max-width': ''});
    $('.patient_calendar').css({'max-width': ''});
    $('#activity-show-button').show();
    $('#planning-activity-module').hide();
  });

  $('#unzoom-button').hide();

  $('#zoom-button').click(function(){
    $(this).hide();
    $('#unzoom-button').show();
    $('#planning-container .fc-view > table').css({'width': '300%'})
  });

  $('#unzoom-button').click(function(){
    $(this).hide();
    $('#zoom-button').show();
    $('#planning-container .fc-view > table').css({'width': ''})
  });

  $('#nurse-filter-zentai_').on('change', function(){
    $('.calendar').fullCalendar('rerenderEvents');
  }); 

  $('#patient-filter-zentai_').on('change', function(){
    $('.calendar').fullCalendar('rerenderEvents');
  });


  $('#master-nurse-filter-zentai_').on('change', function(){
    $('.master-calendar').fullCalendar('rerenderEvents');
  }); 

  $('#master-patient-filter-zentai_').on('change', function(){
    $('.master-calendar').fullCalendar('rerenderEvents');
  });

  $('#edit-request-filter').parent().on('change', function(){
    $('.calendar').fullCalendar('rerenderEvents');
  })

  $('#nurse-filter-zentai_').chosen({no_results_text: "ヘルパーが見つかりません"});
  $('#patient-filter-zentai_').chosen({no_results_text: "利用者が見つかりません"});

  $('#master-nurse-filter-zentai_').chosen({no_results_text: "ヘルパーが見つかりません"});
  $('#master-patient-filter-zentai_').chosen({no_results_text: "利用者が見つかりません"});


  $('#trigger-duplication').click(function(){
  	var $this = $(this);
    var template_id = $('#duplicate-from').val() ;
    if (template_id && $this.data('submitted') !== true) {
      $.ajax({
        url: window.duplicateUrl + '?template_id=' + template_id,
        type: 'PATCH',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      });
      $this.data('submitted', true);
    } else if (template_id && $this.data('submitted') === true) {
    	alert('スケジュールの反映中です、少々お待ちください');
    } else {
      alert('反映したいスケジュールを選択してください');
    }

  });

  $('input[type="checkbox"].bootstrap-toggle').change(function(){
    if (window.bootstrapToggleUrl === window.createRecurringAppointmentURL) {
      window.bootstrapToggleUrl = window.createUnavailabilityURL
    } else {
      window.bootstrapToggleUrl =  window.createRecurringAppointmentURL
    }
  });


  $('#print-button').click(function(){
  	var confirm = window.confirm('サービスのコメントを含めて印刷する。');
  	if (confirm == true) {
      $('#recurring-appointment-details-container').removeClass('no-print');
  		window.print();
  	} else {
  		$('#recurring-appointment-details-container').addClass('no-print');
  		window.print();
  	}
    
  });

  $('#master-print-button').click(function(){
    window.print();
  });

  $('.resource-list-element').click(function(){
    window.location = $(this).data('url');
  });

  $('#toggle-patients-nurses').bootstrapToggle({
    on: '利用者',
    off: 'ヘルパー',
    onstyle: 'info',
    offstyle: 'info',
    width: 100
  });

  $('#toggle-patients-nurses').on('change', function(){
    $('#patients-resource').toggleClass('hide-resource');
    $('#nurses-resource').toggleClass('hide-resource');
  });



  $('.master-list-element').click(function(){
    $('.master-list-element').removeClass('master-element-selected');
    $(this).addClass('master-element-selected');
    loadMasterAppointmentDetails();
    synchronizeMasterTitle();
    synchronizeMasterAddressAndPhone();
    $('.master-calendar').fullCalendar('rerenderEvents');
  });

  $('#account-settings-dropdown').hide();

  $('#account-settings').click(function(){
    $('#account-settings-dropdown').toggle();
  });

  $('li.account-settings-li').click(function(){
    window.location = $(this).data('url');
  })

  

  

}); 

