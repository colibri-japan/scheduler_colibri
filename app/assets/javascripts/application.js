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
//= require popper
//= require bootstrap
//= require bootstrap-toggle
//= require moment.min
//= require chosen.jquery
//= require popper
//= require fullcalendar
//= require locale-all
//= require scheduler
//= require daterangepicker
//= require select2-full
//= require select2_locale_ja
//= require Chart.bundle
//= require chartkick
//= require_tree .


var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  
  $('.nurse_calendar').each(function(){
    var nurse_calendar = $(this);
    nurse_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
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
      firstDay: window.firstDay,
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      validRange: {
        start: window.validRangeStart,
        end: moment(window.validRangeStart).add(1, 'months').format("YYYY-MM-DD"),
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
      eventColor: '#7AD5DE',
      events: window.appointmentsURL + '&master=false',


      select: function(start, end, jsEvent, view, resource) {
        $.getScript(window.createRecurringAppointmentURL, function() {
          
          masterSwitchToggle();
          toggleEditRequested();

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


        	$('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
        	$('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));

          if (view.name == 'month') {
            $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
            $('#recurring_appointment_ends_at_4i').val(23);
            $('#recurring_appointment_ends_at_5i').val(59);
          } else {
            $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(end).format('D')); 
            $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
            $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
          }

          $("#recurring_appointment_nurse_id").val(window.nurseId);
          
          recurringAppointmentFormChosen();
        });

        nurse_calendar.fullCalendar('unselect');
      },

      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },

      eventRender: function(event, element, view){
        if (window.eventDragging) {
          return
        }
        if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #ddd, #ddd 5px, #FFBBA0 5px, #FFBBA0 10px)' });
        }
        element.popover({
          title: event.service_type,
          content: event.description,
          trigger: 'hover',
          placement: 'top',
          container: 'body'
        });
        element.find('.fc-title').text(function(i, t){
          return event.patient_name;
        });
        return event.displayable;
      },
         
      eventClick: function(event, jsEvent, view) {
          $.getScript(event.edit_url, function() {
            masterSwitchToggle();
            appointmentFormChosen();
            toggleEditRequested();
            appointmentEdit(event.recurring_appointment_path);

          });
      },

      eventAfterAllRender: function (view) {
        appointmentComments();
      },


      eventDrop: function (event, delta, revertFunc) {
        $(".popover").remove()
        let minutes = moment.duration(delta).asMinutes();
        let start_time = event.start
        let end_time = event.end
        let previous_start = moment(start_time).subtract(minutes, "minutes");
        let previous_end = moment(end_time).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]d[日]') + '(' + previous_start.format('dddd').charAt(0) + ') ' + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = start_time.format('M[月]d[日]') + '(' + start_time.format('dddd').charAt(0) + ') ' + start_time.format('LT') + ' ~ ' + end_time.format('LT')

        $('#drag-drop-content').html("<p>ヘルパー： " + event.nurse_name + '  / 利用者名： ' + event.patient_name + "</p> <p>" + previousAppointment + " >> </p><p>" + newAppointment + "</p>")
        $('#drag-drop-confirm').data('event', event)
        $('#drag-drop-confirm').data('delta', delta)
        $('#drag-drop-confirm').dialog({
          height: 'auto',
          width: 400,
          modal: true,
          buttons: {
            'セーブする': function () {
              let appointment = $(this).data('event');
              let delta = $(this).data('delta');
              appointment_data = {
                appointment: {
                  starts_at: appointment.start.format(),
                  ends_at: appointment.end.format(),
                }
              };
              $.ajax({
                url: event.base_url + '.js?delta=' + delta,
                type: 'PATCH',
                beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
                data: appointment_data,
                success: function (data) {
                  $(".popover").remove();
                  if (data.includes("その日のヘルパーが重複しています")) {
                    revertFunc();
                  }
                }
              });
              $(this).dialog("close")
            },
            "キャンセル": function () {
              $(this).dialog("close");
              revertFunc()
            }
          }
        })
        $('.ui-dialog-titlebar-close').click(function(){
          revertFunc();
        })
      },

      dayRender: function(date, cell) {
        let holidays = JSON.parse(window.holidays);
        if (holidays.length > 0) {
          let dates = [];
          holidays.forEach(function(holidayObject){
            dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"));
          });
          if (dates.indexOf(moment(date).format('YYYY-MM-DD')) > -1) {
            let day_cells = $("[data-date = " + moment(date).format('YYYY-MM-DD') + "]");
            day_cells.css('background-color', '#FFE8E8')
          }
        }
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
      defaultView: window.defaultView,
      minTime: window.minTime,
      maxTime: window.maxTime, 
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      locale: 'ja',
      firstDay: window.firstDay,
      eventColor: '#7AD5DE',
      validRange: {
        start: window.validRangeStart,
        end: moment(window.validRangeStart).add(1, 'months').format("YYYY-MM-DD"),
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
      eventSources: [window.appointmentsURL + '&master=false', window.unavailabilitiesUrl + '&master=false'],


      select: function (start, end, jsEvent, view, resource) {
        $.getScript(window.bootstrapToggleUrl, function() {
          
          masterSwitchToggle();
          toggleEditRequested();

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


          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));        	         
          $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
          if (view.name == 'month') {
            $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
            $('#recurring_appointment_ends_at_4i').val(23);
            $('#recurring_appointment_ends_at_5i').val(59);
          } else {
            $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
            $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
            $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
          }

          $("#recurring_appointment_patient_id").val(window.patientId);

          $('#unavailability_starts_at_1i').val(moment(start).format('YYYY'));
          $('#unavailability_starts_at_2i').val(moment(start).format('M'));
          $('#unavailability_starts_at_3i').val(moment(start).format('D'));
          $('#unavailability_starts_at_4i').val(moment(start).format('HH'));
          $('#unavailability_starts_at_5i').val(moment(start).format('mm'));
          $('#unavailability_ends_at_1i').val(moment(end).format('YYYY'));
          $('#unavailability_ends_at_2i').val(moment(end).format('M'));
          $('#unavailability_ends_at_3i').val(moment(end).format('D'));
          $('#unavailability_ends_at_4i').val(moment(end).format('HH'));
          $('#unavailability_ends_at_5i').val(moment(end).format('mm'));
          $("#unavailability_patient_id").val(window.patientId);

          recurringAppointmentFormChosen();
        });


        patient_calendar.fullCalendar('unselect');
      },


      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },

      eventRender: function (event, element, view){
        if (window.eventDragging) {
          return
        }
        if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #ddd, #ddd 5px, #FFBBA0 5px, #FFBBA0 10px)' });
        }
        element.popover({
          title: event.service_type,
          content: event.description,
          trigger: 'hover',
          placement: 'top',
          container: 'body'
        });
        element.find('.fc-title').text(function(i, t){
          return event.nurse_name;
        });
        return event.displayable;
      },


      eventDrop: function (event, delta, revertFunc) {
        $(".popover").remove()
        let minutes = moment.duration(delta).asMinutes();
        let start_time = event.start 
        let end_time = event.end 
        let previous_start = moment(start_time).subtract(minutes, "minutes");
        let previous_end = moment(end_time).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]d[日]') + '(' + previous_start.format('dddd').charAt(0) + ') ' + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = start_time.format('M[月]d[日]') + '(' + start_time.format('dddd').charAt(0) + ') ' + start_time.format('LT') + ' ~ ' + end_time.format('LT')

        $('#drag-drop-content').html("<p>ヘルパー： " + event.nurse_name + '  / 利用者名： ' + event.patient_name +  "</p> <p>" + previousAppointment + " >> </p><p>"+ newAppointment +  "</p>")
        $('#drag-drop-confirm').data('event', event)
        $('#drag-drop-confirm').data('delta', delta)
        $('#drag-drop-confirm').dialog({
          height: 'auto',
          width: 400,
          modal: true,
          buttons: {
            'セーブする': function(){
              let appointment = $(this).data('event');
              let delta = $(this).data('delta');
              appointment_data = {
                appointment: {
                  starts_at: appointment.start.format(),
                  ends_at: appointment.end.format(),
                }
              };
              $.ajax({
                url: event.base_url + '.js?delta=' + delta,
                type: 'PATCH',
                beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
                data: appointment_data,
                success: function(data) {
                  $(".popover").remove();
                  if(data.includes("その日のヘルパーが重複しています")) {
                    revertFunc();
                  } 
                }
              });
              $(this).dialog("close")
            },
            "キャンセル": function() {
              $(this).dialog("close");
              revertFunc()
            }
          }
        })
        $('.ui-dialog-titlebar-close').click(function () {
          revertFunc();
        })    
      },
         
      eventClick: function(event, jsEvent, view) {
           $.getScript(event.edit_url, function() {
            masterSwitchToggle();
            appointmentFormChosen();
            toggleEditRequested();
            console.log(event.recurring_appointment_path)
            appointmentEdit(event.recurring_appointment_path);
           });
         },

      eventAfterAllRender: function (view) {
        appointmentComments();
      },

      dayRender: function (date, cell) {
        let holidays = JSON.parse(window.holidays);
        if (holidays.length > 0) {
          let dates = [];
          holidays.forEach(function (holidayObject) {
            dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"));
          });
          if (dates.indexOf(moment(date).format('YYYY-MM-DD')) > -1) {
            let day_cells = $("[data-date = " + moment(date).format('YYYY-MM-DD') + "]");
            day_cells.css('background-color', '#FFE8E8')
          }
        }
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
      firstDay: window.firstDay,
      nowIndicator: true,
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: moment(window.validRangeStart).add(1, 'months').format("YYYY-MM-DD"),
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
      editable: true,
      eventColor: '#7AD5DE',
      refetchResourcesOnNavigate: true,


      resources: {
        url: window.corporationNursesURL　+ '?include_undefined=true&master=true',
      },

      events: window.appointmentsURL + '&master=true',


      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },


      eventRender: function eventRender(event, element, view) {
        if (window.eventDragging) {
          return
        }
        if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #ddd, #ddd 5px, #FFBBA0 5px, #FFBBA0 10px)' });
        }
        element.popover({
          title: event.service_type,
          content: event.description,
          trigger: 'hover',
          placement: 'top',
          container: 'body'
        })

        if (view.name != 'agendaDay') {
            $('#nurse-info-block-master').removeClass('.print-master-no-view');
            element.find('.fc-title').text(function(i,t){
              if ($('#toggle-patients-nurses').is(':checked')) {
                return event.nurse_name;
              } else {
                return event.patient_name;
              }
            });


            return  !event.edit_requested && event.master && event.displayable ;
          } else {
            $('#nurse-info-block-master').addClass('.print-master-no-view');
            return !event.edit_requested && event.master && event.displayable ;
          }
      },

      eventDrop: function (event, delta, revertFunc) {
        $('.popover').remove()
        let minutes = moment.duration(delta).asMinutes();
        let start_time = event.start;
        let end_time = event.end;
        let previous_start = moment(start_time).subtract(minutes, "minutes");
        let previous_end = moment(end_time).subtract(minutes, "minutes");
        let frequency = humanizeFrequency(event.frequency);
        let newAppointment =  '(' + start_time.format('dddd').charAt(0) + ') ' + frequency + ' ' + start_time.format('LT') + ' ~ ' + end_time.format('LT')
        

        $('#drag-drop-master-content').html("<p>ヘルパー： " + event.nurse_name + '  / 利用者名： ' + event.patient_name + "</p><p>"  + newAppointment + "</p>")

        $('#drag-drop-master').dialog({
          height: 'auto',
          width: 400,
          modal: true,
          buttons: {
            'コピーする': function(){
              $(this).dialog("close");
              $.ajax({
                url: "/plannings/" + window.planningId + "/recurring_appointments.js",
                type: 'POST',
                data: {
                  recurring_appointment: {
                    nurse_id: event.nurse_id,
                    patient_id: event.patient_id,
                    frequency: event.frequency,
                    title: event.service_type,
                    color: event.color,
                    anchor: event.start.format('YYYY-MM-DD'),
                    end_day: event.end.format('YYYY-MM-DD'),
                    starts_at: event.start.format(),
                    ends_at: event.end.format()
                  },
                  master: true
                },
                beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
                success: function (data) {
                  $(".popover").remove();
                  if (data.includes("のヘルパーが重複しています")) {
                    revertFunc();
                  }
                }
              });
              revertFunc();
            },
            'キャンセル': function(){
              $(this).dialog("close");
              revertFunc();
            }
          }
        });

        $('.ui-dialog-titlebar-close').click(function () {
          revertFunc();
        })  
      },


      select: function(start, end, jsEvent, view, resource) {
        $.getScript(window.createRecurringAppointmentURL + '?master=true', function() {
          
          masterSwitchToggle();
          toggleEditRequested();

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


          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
          if (view.name == 'month') {
            $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
            $('#recurring_appointment_ends_at_4i').val(23);
            $('#recurring_appointment_ends_at_5i').val(59);
          } else {
            $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
            $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
            $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
          }
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
         
      eventClick: function (event, jsEvent, view) {
            if (window.userIsAdmin == 'true') {
              $.getScript(event.recurring_appointment_path + '?master=true', function() {

                masterSwitchToggle();
                recurringAppointmentEditButtons();
                recurringAppointmentFormChosen();
                editAfterDate();
                individualMasterToGeneral();
                toggleEditRequested();
                recurringAppointmentArchive();
              });
            }
            return false;
         },
      
      eventAfterAllRender: function(view) {
        appointmentComments();
      },

      dayRender: function (date, cell) {
        let holidays = JSON.parse(window.holidays);
        if (holidays.length > 0) {
          let dates = [];
          holidays.forEach(function (holidayObject) {
            dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"));
          });
          if (dates.indexOf(moment(date).format('YYYY-MM-DD')) > -1) {
            let day_cells = $("[data-date = " + moment(date).format('YYYY-MM-DD') + "]");
            day_cells.css('background-color', '#FFE8E8')
          }
        }
      }
    })
    
  });
};

var initialize_calendar;
initialize_calendar = function() {
  let myResource;
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
      firstDay: window.firstDay,
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: moment(window.validRangeStart).add(1, 'months').format("YYYY-MM-DD"),
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
      refetchResourcesOnNavigate: true,

      resources: {
        url: window.resourceUrl + '?include_undefined=true&master=false&planning_id=' + window.planningId,
      }, 

      eventSources: [ window.appointmentsURL, window.unavailabilitiesUrl],


      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
        myResource = $('.calendar').fullCalendar('getResourceById', event.resourceId);
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },


      eventRender: function eventRender(event, element, view) {
        if (window.eventDragging) {
          return
        }
        if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #ddd, #ddd 5px, #FFBBA0 5px, #FFBBA0 10px)' });
        } 
        element.popover({
          title: event.service_type,
          content: event.description,
          trigger: 'hover',
          placement: 'top',
          container: 'body'
        })

        if (view.name == 'agendaDay') {
          element.find('.fc-title').text(function(i, t){
            if ($('#day-view-options-input').is(':checked')) {
              return event.patient_name;
            } else {
              return event.nurse_name;
            }
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
            if (event.patient_id) {
              if (['', event.patient_id.toString()].indexOf(patientFilterArray[i]) >= 0) {
                return true
              }
            } 
          }
          return false
        }
        var filterNurse = function() {
          for (var i=0; i< nurseFilterArray.length; i++) {
            if (event.nurse_id) {
              if (['', event.nurse_id.toString()].indexOf(nurseFilterArray[i]) >= 0) {
                return true
              }
            } else {
              if (event.unavailability) {
                return true
              }
            }
          }
          return false
        } 
        var filterEditRequested = function(){
          if (editRequestFilter == false) {
            return event.edit_requested;
          } else {
            return true;
          }
        }

        return filterPatient() && filterNurse() && filterEditRequested() ;
      },




      select: function(start, end, jsEvent, view, resource) {
      	$.getScript(window.bootstrapToggleUrl, function() {
          
          masterSwitchToggle();
          toggleEditRequested();

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




          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
          if (view.name == 'month') {
            $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
            $('#recurring_appointment_ends_at_4i').val(23);
            $('#recurring_appointment_ends_at_5i').val(59);
          } else {
            $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
            $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
            $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
            $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
            $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
          }


          $('#unavailability_starts_at_1i').val(moment(start).format('YYYY'));
          $('#unavailability_starts_at_2i').val(moment(start).format('M'));
          $('#unavailability_starts_at_3i').val(moment(start).format('D'));
          $('#unavailability_starts_at_4i').val(moment(start).format('HH'));
          $('#unavailability_starts_at_5i').val(moment(start).format('mm'));
          $('#unavailability_ends_at_1i').val(moment(end).format('YYYY'));
          $('#unavailability_ends_at_2i').val(moment(end).format('M'));
          $('#unavailability_ends_at_3i').val(moment(end).format('D'));
          $('#unavailability_ends_at_4i').val(moment(end).format('HH'));
          $('#unavailability_ends_at_5i').val(moment(end).format('mm'));
          if (view.name == 'agendaDay') {
            $('#recurring_appointment_nurse_id').val(resource.id);
          }
          recurringAppointmentFormChosen();

        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function (event, delta, revertFunc) {
        $('.popover').remove()
        let minutes = moment.duration(delta).asMinutes();
        let start_time = event.start
        let end_time = event.end
        let previous_start = moment(start_time).subtract(minutes, "minutes");
        let previous_end = moment(end_time).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]d[日]') + '(' + previous_start.format('dddd').charAt(0) + ') ' + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = start_time.format('M[月]d[日]') + '(' + start_time.format('dddd').charAt(0) + ') ' + start_time.format('LT') + ' ~ ' + end_time.format('LT')
        let newResource = $('.calendar').fullCalendar('getResourceById', event.resourceId)
        let resourceChange = '';
        let newPatientId;
        let newNurseId;

        if (newResource !== myResource) {
          if (newResource.is_nurse_resource) {
            resourceChange = '新規ヘルパー：' + newResource.title  + '</p><p>' ;
            newNurseId = newResource.id;
            newPatientId = event.patient_id;
          } else {
            resourceChange = '新規利用者：' + newResource.title  + '</p><p>' ;
            newPatientId = newResource.id;
            newNurseId = event.nurse_id;
          }
        } else {
          if (newResource.is_nurse_resource) {
            newNurseId = event.nurse_id;
            newPatientId = event.patient_id
          } else {
            newNurseId = event.nurse_id;
            newPatientId = event.patient_id
          }
        }

        $('#drag-drop-content').html("<p>ヘルパー： " + event.nurse_name + '  / 利用者名： ' + event.patient_name + "</p> <p>" + resourceChange + previousAppointment + " >> </p><p>" + newAppointment + "</p>")
        $('#drag-drop-confirm').data('event', event)
        $('#drag-drop-confirm').data('delta', delta)
        $('#drag-drop-confirm').dialog({
          height: 'auto',  
          width: 400,
          modal: true,
          buttons: {
            'セーブする': function () {
              let appointment = $(this).data('event');
              let delta = $(this).data('delta');
              appointment_data = {
                appointment: {
                  starts_at: appointment.start.format(),
                  ends_at: appointment.end.format(),
                  patient_id: newPatientId,
                  nurse_id: newNurseId,
                }
              };
              $.ajax({
                url: event.base_url + '.js?delta=' + delta,
                type: 'PATCH',
                beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
                data: appointment_data,
                success: function (data) {
                  $(".popover").remove();
                  if (data.includes("その日のヘルパーが重複しています")) {
                    revertFunc();
                  }
                }
              });

              $('.calendar').fullCalendar('')
              $(this).dialog("close")
            },
            "キャンセル": function () {
              $(this).dialog("close");
              revertFunc()
            }
          }
        })
        $('.ui-dialog-titlebar-close').click(function () {
          revertFunc();
        })
      },
         
      eventClick: function(event, jsEvent, view) {
           $.getScript(event.edit_url, function() {
            masterSwitchToggle();
            appointmentFormChosen();
            toggleEditRequested();
            appointmentEdit(event.recurring_appointment_path);
           });

         },

      eventAfterAllRender: function (view) {
        appointmentComments();
      },

      viewRender: function(view){
        if (view.name == 'agendaDay') {
          $('span#day-view-options').show();
        } else {
          $('span#day-view-options').hide();
        }
      },

      dayRender: function (date, cell) {
        let holidays = JSON.parse(window.holidays);
        if (holidays.length > 0) {
          let dates = [];
          holidays.forEach(function (holidayObject) {
            dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"));
          });
          if (dates.indexOf(moment(date).format('YYYY-MM-DD')) > -1) {
            let day_cells = $("[data-date = " + moment(date).format('YYYY-MM-DD') + "]");
            day_cells.css('background-color', '#FFE8E8')
          }
        }
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


var toggleProvidedServiceForm;
toggleProvidedServiceForm = function(){
  if ($('#hour-based-wage-toggle').is(':checked') && $('#hour-input-method').is(':checked')) {
    $("label[for='provided_service_unit_cost']").text('時給');
    $('#pay-by-hour-field').show();
    $('#pay-by-count-field').hide();
    $('#provided_service_service_duration').hide();
    $('#target-service-from-ids').show();
  } else if ($('#hour-based-wage-toggle').is(':checked') && !$('#hour-input-method').is(':checked')) {
    $("label[for='provided_service_unit_cost']").text('時給');
    $('#pay-by-hour-field').show();
    $('#pay-by-count-field').hide();
    $('#provided_service_service_duration').show();
    $('#target-service-from-ids').hide();
  } else if (!$('#hour-based-wage-toggle').is(':checked') && $('#count-input-method').is(':checked')) {
    $("label[for='provided_service_unit_cost']").text('単価');
    $('#pay-by-hour-field').hide();
    $('#pay-by-count-field').show();
    $('#target-service-from-ids').show();
    $('#provided_service_service_counts').hide();
  } else if (!$('#hour-based-wage-toggle').is(':checked') && !$('#count-input-method').is(':checked')) {
    $("label[for='provided_service_unit_cost']").text('単価');
    $('#pay-by-hour-field').hide();
    $('#pay-by-count-field').show();
    $('#target-service-from-ids').hide();
    $('#provided_service_service_counts').show();
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

  $('#hour-input-method').change(function(){
    toggleProvidedServiceForm();
  });

  $('#count-input-method').change(function(){
    toggleProvidedServiceForm();
  })

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

let toggleEditRequested = () => {
  let $this  = $('.edit-requested-toggle')
  let requested = $this.data('requested')
  let onText = requested ? '残す' : '追加する';
  let offText = requested ? '出す' : '追加しない';
  $this.bootstrapToggle({
    on: onText,
    off: offText,
    onstyle: 'success',
    offstyle: 'secondary',
    width: 120
  })
}

let recurringAppointmentArchive = () => {
  $('#recurring-appointment-archive').click(function(){
    let archiveUrl = $(this).data('archive-url');
    let val = $('select#recurring_appointment_editing_occurrences_after').val();
    let message = confirm('選択された繰り返しが削除されます。');
    if (message) {
      $.ajax({
        url: archiveUrl,
        type: 'PATCH',
        data: {
          recurring_appointment: {
            editing_occurrences_after: val,
          }
        },
        beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
      })
    }
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

let appointmentEdit = (url) => {
  if (url) {
    $('#edit-appointment-body').hide();
    $('#one-day-edit').click(function () {
      $('#edit-options').hide();
      $('#edit-appointment-body').show();
    });
    $('#recurring-edit').click(function () {
      $('.modal').modal('hide');
      $('.modal-backdrop').remove();
      let targetUrl = $(this).data('recurring-url');
      $.getScript(targetUrl, function () {
        masterSwitchToggle();
        recurringAppointmentFormChosen();
        recurringAppointmentEditButtons();
        editAfterDate();
        toggleEditRequested();
        recurringAppointmentArchive();
      })
    })
  } else {
    $('#edit-options').hide();

  }

}

let sendReminder = () => {
  $('#send-email-reminder').click(function () {

    let customSubject = $('#nurse_custom_email_subject').val();
    let customMessage = $('#nurse_custom_email_message').val();
    let customDays = $('#chosen-custom-email-days').val();
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
      beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) }
    })
  })
}

let toggleCountFromServices = () => {
  $('#hour-input-method').bootstrapToggle({
    on: '自動',
    off: '手動',
    onstyle: 'success',
    offstyle: 'info',
    width: 130
  });
  $('#count-input-method').bootstrapToggle({
    on: '自動',
    off: '手動',
    onstyle: 'success',
    offstyle: 'info',
    width: 130
  })
}

let humanizeFrequency = (frequency) => {
  console.log(frequency)
  switch(frequency) {
    case 0:
      return '毎週';
      break;
    case 1:
      return '第一、三、五週目';
      break;
    case 2:
      return 'その日のみ'
      break;
    case 3:
      return '第二、四週目';
      break;
    case 4:
      return '第一週目';
      break;
    case 5:
      return '最後の週';
      break;
    default:
  }
}
let allMasterToSchedule = () => {
  var copyMasterState;
  $('#copy-master').click(function () {
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
  });
}


let patientMasterToSchedule = () => {
  let copyPatientMasterState;
  $('#copy-master-patient').click(function(){
    if (copyPatientMasterState == 1) {
      alert('利用者のサービスを全体へコピーしてます、少々お待ちください');
    } else {
      var message = confirm('利用者の「全体」のサービスが削除され、マスターのサービスがすべて全体へ反映されます！');
      if (message && copyPatientMasterState != 1) {
        copyPatientMasterState = 1;
        $.ajax({
          url: window.patientMasterToSchedule,
          type: 'PATCH',
          beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
        })
      }
    }
  })
}

let nurseMasterToSchedule = () => {
  let copyNurseMasterState;
  $('#copy-master-nurse').click(function () {
    if (copyNurseMasterState == 1) {
      alert('ヘルパーのサービスを全体へコピーしてます、少々お待ちください');
    } else {
      var message = confirm('ヘルパーの「全体」のサービスが削除され、マスターのサービスがすべて全体へ反映されます！');
      if (message && copyNurseMasterState != 1) {
        copyNurseMasterState = 1;
        $.ajax({
          url: window.nurseMasterToSchedule,
          type: 'PATCH',
          beforeSend: function (xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) },
        })
      }
    }
  })
}

let toggleDayResources = () => {
  if ($('#day-view-options-input').is(':checked')) {
    window.resourceUrl = window.corporationNursesUrl;
    $('.calendar').fullCalendar('option', 'resources', window.resourceUrl + '?include_undefined=true&master=false');
    $('.calendar').fullCalendar('refetchResources');
    $('.calendar').fullCalendar('clientEvents').forEach(function (event) {
      event.resourceId = event.nurse_id;
      $('.calendar').fullCalendar('updateEvent', event);
    })
  } else {
    window.resourceUrl = window.corporationPatientsUrl;
    $('.calendar').fullCalendar('option', 'resources', window.resourceUrl + '?include_undefined=true&master=false&planning_id=' + window.planningId);
    $('.calendar').fullCalendar('refetchResources');
    $('.calendar').fullCalendar('clientEvents').forEach(function(event){
      event.resourceId = event.patient_id;
      $('.calendar').fullCalendar('updateEvent', event);
    })
  }
}

let recurringAppointmentsSelect =  () => {
  $('#recurring_appointment_title').select2({
    tags: true,
    theme: 'bootstrap',
    language: 'ja',
  });
};

let appointmentsSelect = () => {
  let parent;
  $('#appointment_title').select2({
    tags: true,
    theme: 'bootstrap',
    language: 'ja',
  })
}

let skillsSelect = () => {
  $('#nurse_skill_list').select2({
    tags: true,
    width: '100%',
    theme: 'bootstrap',
    language: 'ja',
  })
}

let patientSelect2 = () => {
  $('#patient_caveat_list').select2({
    tags: true,
    width: '100%',
    theme: 'bootstrap',
    language: 'ja'
  });
};



$(document).on('turbolinks:load', initialize_calendar); 
$(document).on('turbolinks:load', initialize_nurse_calendar); 
$(document).on('turbolinks:load', initialize_patient_calendar); 
$(document).on('turbolinks:load', initialize_master_calendar);

$(document).on('turbolinks:load', function(){

  $('tr.nurse-clickable-row').click(function(){
    $.getScript($(this).data('link'));
  });

  $('tr.patient-clickable-row').click(function () {
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

  $('#payable-download-button').click(function(){
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
    off: "調整中リスト",
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

  $('#new-email-reminder').click(function(){
    let targetPath =  $(this).data('reminder-url');
    $.getScript(targetPath, function(){
      $('#chosen-custom-email-days').chosen({
        disable_search_threshold: 8
      })
      sendReminder();
    })
  })

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

  $('#drag-drop-confirm').hide();



  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove(); 
      });
  }, 4000);

  

  $('#loader-container').hide();

  $('#master-options').click(function(){
    $('.modal').modal('hide');
    $('.modal-backdrop').remove();
    $('#remote_container').html($('#modal-master-options'));
    $('#modal-master-options').modal('show');
    allMasterToSchedule();
    patientMasterToSchedule();
    nurseMasterToSchedule();
  });

  $('#drag-drop-master').hide();

  $('#day-view-options').hide();






  

}); 

