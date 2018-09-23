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
//= require jquery-ui
//= require bootstrap
//= require bootstrap-toggle
//= require moment.min
//= require chosen.jquery
//= require popper
//= require fullcalendar
//= require locale-all
//= require scheduler
//= require daterangepicker
//= require Chart.bundle
//= require chartkick
//= require_tree .


var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  
  $('.nurse_calendar').each(function(){
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
        },
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
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
      events: window.appointmentsURL,


      select: function(start, end) {
        $.getScript(window.createRecurringAppointmentURL, function() {
          
          masterSwitchToggle();

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
          
          recurringAppointmentFormChosen();
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
          $.getScript(event.edit_url, function() {
            masterSwitchToggle();
            addToEditListButton();
            appointmentFormChosen();

            $('#edit-all-occurrences').click(function(){
              var editUrl = $(this).data('edit-url');
              $('.modal').on('hidden.bs.modal', function () {
                $.getScript(editUrl, function () {
                  masterSwitchToggle();
                  recurringAppointmentFormChosen();
                  recurringAppointmentEditButtons();
                  editAfterDate();
                  deleteRecurringAppointment();
                })
              });
              $('.modal').modal('hide');
            });
          });
      },

      eventAfterAllRender: function (view) {
        appointmentComments();
      }



    })
  })
}


var initialize_patient_calendar;
initialize_patient_calendar = function(){
  
  $('.patient_calendar').each(function(){
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
      views: {
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
        }
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
      eventSources: [ window.appointmentsURL, window.unavailabilitiesUrl],


      select: function(start, end) {
        $.getScript(window.bootstrapToggleUrl, function() {
          
          masterSwitchToggle();

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

          recurringAppointmentFormChosen();
        });


        patient_calendar.fullCalendar('unselect');
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
            masterSwitchToggle();
            addToEditListButton();
            appointmentFormChosen();

            $('#edit-all-occurrences').click(function(){
              var editUrl = $(this).data('edit-url');
              $('.modal').on('hidden.bs.modal', function () {
                $.getScript(editUrl, function () {
                  masterSwitchToggle();
                  recurringAppointmentFormChosen();
                  recurringAppointmentEditButtons();
                  editAfterDate();
                  deleteRecurringAppointment();
                })
              });
              $('.modal').modal('hide');
            });

            
           });
         },

      eventAfterAllRender: function (view) {
        appointmentComments();
      }

    });
  })
};

var initialize_master_calendar;
initialize_master_calendar = function() {
  $('.master_calendar').each(function(){
    var master_calendar = $(this);
    master_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      views: {
      	agendaThreeDay: {
      		type: 'agenda',
      		duration: {days: 3},
      		buttonText: '３日'
      	},
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
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

      events: window.appointmentsURL + '&master=true',

      eventRender: function eventRender(event, element, view) {
        if (view.name != 'agendaDay') {
            $('#nurse-info-block-master').removeClass('.print-master-no-view');
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

            return filterName() && !event.editRequested && event.master && event.displayable ;
          } else {
            $('.master-title').text('全サービス');
            $('#nurse-info-block-master').addClass('.print-master-no-view');
            return !event.editRequested && event.master && event.displayable ;
          }
      },


      select: function(start, end, jsEvent, view, resource) {
        $.getScript(window.createRecurringAppointmentURL + '?master=true', function() {
          
          masterSwitchToggle();

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
          if (window.nurseId) {
            $('#recurring_appointment_nurse_id').val(window.nurseId);
          }
          if (window.patientId) {
            $('#recurring_appointment_patient_id').val(window.patientId);
          }
          recurringAppointmentFormChosen();

        });

        master_calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               start: appointment.start.format(),
               end: appointment.end.format()
             }
           };
           $.ajax({
               url: appointment.base_url + '.js?master=true',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
            if (window.userIsAdmin == 'true') {
              $.getScript(appointment.edit_url + '?master=true', function() {
                masterSwitchToggle();
                appointmentFormChosen();

                $('#edit-all-occurrences').click(function(){
                  var editUrl = $(this).data('edit-url');
                  $('.modal').on('hidden.bs.modal', function () {
                    $.getScript(editUrl, function () {
                      masterSwitchToggle();
                      recurringAppointmentEditButtons();
                      recurringAppointmentFormChosen();
                      editAfterDate();
                      deleteRecurringAppointment();
                      individualMasterToGeneral();
                    })
                  });
                  $('.modal').modal('hide');
                })
              });
            }
            return false;
         },
      
      eventAfterAllRender: function(view) {
        appointmentComments();
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
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
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
      selectable: true,
      selectHelper: false,
      editable: true,
      eventLimit: true,
      eventColor: '#7AD5DE',


      resources: {
        url: window.corporationNursesURL + '?include_undefined=true',
      }, 

      eventSources: [ window.appointmentsURL, window.unavailabilitiesUrl],

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




      select: function(start, end, jsEvent, view, resource) {
      	$.getScript(window.bootstrapToggleUrl, function() {
          
          masterSwitchToggle();

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
          recurringAppointmentFormChosen();

        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
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
           $.getScript(appointment.edit_url, function() {
            masterSwitchToggle();
            addToEditListButton();
            appointmentFormChosen();

            $('#edit-all-occurrences').click(function(){
              var editUrl = $(this).data('edit-url');
              $('.modal').on('hidden.bs.modal', function(){
                $.getScript( editUrl , function(){
                    masterSwitchToggle();
                    recurringAppointmentFormChosen();
                    recurringAppointmentEditButtons();
                    editAfterDate();
                    deleteRecurringAppointment();
                })
              });
              $('.modal').modal('hide');
            })
           });

         },

      eventAfterAllRender: function (view) {
        appointmentComments();
      }
    });
  });
};


var appointmentFormChosen;
appointmentFormChosen = function(){
  $('#appointment_nurse_id').chosen({
    no_results_text: 'ヘルパーが見つかりません',
  });
  $('#appointment_patient_id').chosen({
    no_results_text: '利用者が見つかりません',
  })
}

var recurringAppointmentFormChosen;
recurringAppointmentFormChosen = function(){
  $('#recurring_appointment_nurse_id').chosen({
    no_results_text: 'ヘルパーが見つかりません',
  });
  $('#recurring_appointment_patient_id').chosen({
    no_results_text: '利用者が見つかりません',
  })
}

var masterSwitchToggle;
masterSwitchToggle = function() {
  $('.master-toggle').bootstrapToggle({
   on: 'マスター',
   off: '普通',
   size: 'normal',
   onstyle: 'success',
   offstyle: 'info',
   width: 100,
  });
}

var addToEditListButton;
addToEditListButton = function(){
  $('#form-edit-list-decoy').click(function(){
    if ($('#recurring_appointment_title').val() == "") {
      alert('サービスタイプを入力してください');
    } else if ($('#recurring_appointment_patient_id').find('option:selected').text() == "利用者選択") {
      alert('利用者を選択してください');
    } else if ($('#recurring_appointment_master').is(":checked")) {
      alert('編集リストへ追加されるサービスはマスターとして登録できません。')
    } else {
      var message = confirm('サービスが編集リストへ追加されます');
      if (message) {
        $('#form-edit-list').click();
      } else {
        return false;
      }
    }
  });
}

var recurringAppointmentEditButtons;
recurringAppointmentEditButtons = function(){
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
  addToEditListButton();
}

var editAfterDate;
editAfterDate = function(){
  $('#delete-recurring-appointment').hide();
  $('#recurring_appointment_editing_occurrences_after option').each(function () {
    var $this = $(this);
    if ($this.val()) {
      var date = moment($(this).text(), 'YYYY-MM-DD');
      $this.text(date.format('M月D日以降'));
    }
  });
}

var deleteRecurringAppointment;
deleteRecurringAppointment = function(){
  $('#delete-recurring-appointment-decoy').click(function(){
    var idSelected = $('#recurring_appointment_editing_occurrences_after').find(':selected').val();
    if (idSelected) {
      var textSelected = $('#recurring_appointment_editing_occurrences_after').find(':selected').text();
      var message = confirm(textSelected + "の繰り返しが削除されます。");
      if (message) {
        var allAppointmentIds = JSON.parse(window.appointmentIds);
        var index = allAppointmentIds.indexOf(parseInt(idSelected));
        var slicedArray = allAppointmentIds.slice(index);

        slicedArray.forEach(id => {
          $.ajax({
            url: window.planningPath + '/appointments/' + id + '.js',
            type: 'DELETE',
            beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
          })
        });

        $('.modal').modal('hide');
      }
    } else {
      var message = confirm('全繰り返しが削除されます');
      if (message) {
        $.ajax({
          url: $('#delete-recurring-appointment').prop('href') + '.js',
          type: 'DELETE',
          beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
        })
      }
    }
  })
}

var toggleProvidedServiceForm;
toggleProvidedServiceForm = function(){
  if ($('#hour-based-wage-toggle').is(':checked')) {
    $("label[for='provided_service_unit_cost']").text('時給');
    $('#pay-by-hour-field').show();
    $('#pay-by-count-field').hide();
  } else {
    $("label[for='provided_service_unit_cost']").text('単価');
    $('#pay-by-hour-field').hide();
    $('#pay-by-count-field').show();
  }
}

var appointmentComments;
appointmentComments = function() {
  $('#appointment-comments').empty();
  if ($('.master_calendar').length) {
    var calendar = $('.master_calendar');
  } else if ($('.calendar').length) {
    var calendar = $('.calendar');
  } else if ($('.patient_calendar').length) {
    var calendar = $('.patient_calendar');
  } else if ($('.nurse_calendar').length) {
    var calendar = $('.nurse_calendar');
  }

  var clientEvents = calendar.fullCalendar('clientEvents');

  clientEvents.forEach(event => {
    if (event.description) {
      var stringToAppend =　event.start.format('M月D日　H:mm ~ ') + event.end.format('H:mm') + ' ヘルパー：' + event.nurse_name + ' 利用者：' + event.patient_name + ' ' + event.description;
      $('#appointment-comments').append("<p class='appointment-comment'>" + stringToAppend + "</p>")
    }
  })
  
}

var addProvidedServiceToggle;
addProvidedServiceToggle = function(){
  $('#hour-based-wage-toggle').bootstrapToggle({
    on: '時給計算',
    off: '単価計算',
    onstyle: 'success',
    offstyle: 'info',
    width: 100
  });

  toggleProvidedServiceForm();

  $('#hour-based-wage-toggle').change(function(){
    toggleProvidedServiceForm();
  });

  $('#chosen-target-services').chosen({
    no_results_text: 'サービスが見つかりません',
    placeholder_text_multiple: 'サービスを選択してください'
  });
};

var individualMasterToGeneral;
individualMasterToGeneral = function(){
  var copyState;
  $('#individual-from-master-to-general').click(function () {
    var target_url = $(this).data('master-to-general-url');
    if (copyState !== 1) {
      var message = confirm('選択中の繰り返しサービスが全体スケジュールへ反映されます。現在の全体スケジュールは削除されません。');
      if (message) {
        copyState = 1;
        $.ajax({
          url: target_url,
          type: 'PATCH',
          beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
        });
      }
    } else {
      alert('サービスがコピーされてます、少々お待ちください');
    }

  })
}

var toggleFulltimeEmployee;
toggleFulltimeEmployee = function(){
  $('#full-timer-toggle').bootstrapToggle({
    on: '正社員',
    off: '非正社員',
    size: 'normal',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170
  });
}

var toggleReminderable;
toggleReminderable = function(){
  $('#reminderable-toggle').bootstrapToggle({
    on: 'リマインダー送信',
    off: 'リマインダーなし',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170
  })
}

var phoneMailRequirement;
phoneMailRequirement = function(){
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

var providedServicesChosenOptions;
providedServicesChosenOptions = function(){
  $('#select-all-services').click(function(){
    $('#chosen-target-services > option').prop('selected', true);
    $('#chosen-target-services').trigger('chosen:updated');
  });

  $('#unselect-all-services').click(function(){
    $('#chosen-target-services > option').prop('selected', false);
    $('#chosen-target-services').trigger('chosen:updated');
  })
}

$(document).on('turbolinks:load', initialize_calendar); 
$(document).on('turbolinks:load', initialize_nurse_calendar); 
$(document).on('turbolinks:load', initialize_patient_calendar); 
$(document).on('turbolinks:load', initialize_master_calendar);

$(document).on('turbolinks:load', function(){


  $('tr.nurse-clickable-row').click(function(){
    $.getScript($(this).data('link'));
  });

  $('tr.clickable-row').click(function(){
    window.location = $(this).data('link');
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
    if ($this.data('boolean') == true ) {
      $this.find('.switch-input').prop("checked", true);
    }
  });

  $('.switch-input').on('click', function(e){
    e.preventDefault();
    e.stopPropagation();
    return false;
  })

  $('.slider').bind('sendAjax', function(){
    $.ajax({
      url: $(this).data('toggle-url'),
      type: 'PATCH',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    })
  })

  $('.slider').click(function(event){
    var $this = $(this);
    var patientSlider = $this.hasClass('slider-patient');
    if (patientSlider) {
      var isChecked =  $this.prev().is(':checked')
      if (isChecked) {
        var confirmPatient = confirm('選択された利用者の現時点以降のサービスがキャンセルされます。');
        if (confirmPatient) {
          $this.trigger('sendAjax');
        } else {

        }
      } else {
        var confirmPatient = confirm('選択された利用者のキャンセルされたサービスが再起動されます。');
        if (confirmPatient) {
          $this.trigger('sendAjax');
        }
      }
    }
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
    $('.master_calendar').fullCalendar('rerenderEvents');
  }); 

  $('#master-patient-filter-zentai_').on('change', function(){
    $('.master_calendar').fullCalendar('rerenderEvents');
  });

  $('#edit-request-filter').bootstrapToggle({
    on: "全サービス",
    off: "編集リストのみ",
    offstyle: "success",
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

  $('.bootstrap-toggle').bootstrapToggle();

  $('input[type="checkbox"].bootstrap-toggle').change(function(){
    if (window.bootstrapToggleUrl === window.createRecurringAppointmentURL) {
      window.bootstrapToggleUrl = window.createUnavailabilityURL
    } else {
      window.bootstrapToggleUrl =  window.createRecurringAppointmentURL
    }
  });


  $('#print-button').click(function(){
    
    $('#print-options-confirm').dialog({

      resizable: false,
      height: 'auto',
      width: 400,
      modal: true,
      buttons: {
        '表示する':function(){
          $(this).dialog('close');
          $('#recurring-appointment-details-container').removeClass('no-print');
          window.print();
        },
        '表示しない':function(){
          $(this).dialog('close');
          $('#recurring-appointment-details-container').addClass('no-print');
          window.print();
        }
      }
    });
    
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
    window.location = $(this).data('url');
  });

  $('#account-settings-dropdown').hide();

  $('#account-settings').click(function(){
    $('#account-settings-dropdown').toggle();
  });

  $('li.account-settings-li').click(function(){
    window.location = $(this).data('url');
  });

  $('#print-options-confirm').hide();

  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove(); 
      });
  }, 4000);

  var copyMasterState;

  $('#loader-container').hide();

  $('#master-options').click(function(){
    $('.modal').modal('hide');
    $('.modal-backdrop').remove();
    $('#remote_container').html($('#modal-master-options'));
    $('#modal-master-options').modal('show');
    $('#copy-master').click(function(){
      if (copyMasterState == 1) {
        alert('マスターを全体へコピーしてます、少々お待ちください');
      } else {
        var message = confirm('全体のサービスが削除され、マスターのサービスがすべて全体へ反映されます！！数十秒かかる可能性があります。');
        if (message && copyMasterState != 1) {
          copyMasterState = 1;
          $.ajax({
            url: window.masterToSchedule,
            type: 'PATCH',
            beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
          })
        }
      }
    })

  })




  

}); 

