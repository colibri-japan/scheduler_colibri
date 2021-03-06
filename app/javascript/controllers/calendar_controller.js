import { Controller } from "stimulus"

import { Calendar } from '@fullcalendar/core'
import interactionPlugin from '@fullcalendar/interaction'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import listPlugin from '@fullcalendar/list';
import resourcePlugin from '@fullcalendar/resource-common'
import resourceTimeGridPlugin from '@fullcalendar/resource-timegrid'
import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
import jaLocale from '@fullcalendar/core/locales/ja'

require('selectize')
require('selectize/dist/css/selectize.bootstrap3.css')

require('moment')

const moment = require('moment');
import 'moment/locale/ja'
moment.locale('ja')


import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';
import '@fullcalendar/timeline/main.css';
import '@fullcalendar/resource-timeline/main.css';

let resourceHeader = {
    left: 'prev,next today',
    center: 'title',
    right: 'resourceTimeGridDay,resourceTimelineWeek'
}

let header = {
    left: 'prev,next today',
    center: 'title',
    right: 'timeGridDay,timeGridWeek,dayGridMonth'
}

let mobileHeader = {
    left: 'prev,next today',
    center: 'title',
    right: 'listDay,timeGridWeek,dayGridMonth'
}

$.fn.overflownY = function () { var e = this[0]; return e.scrollHeight > e.clientHeight; }

let createCalendar = () => {
    let calendar = new Calendar(document.getElementById('calendar'), {
        plugins: [interactionPlugin, timeGridPlugin, listPlugin, dayGridPlugin, resourcePlugin, resourceTimeGridPlugin, resourceTimelinePlugin],
        schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
        firstDay: window.firstDay,
        slotDuration: '00:15:00',
        timeFormat: 'H:mm',
        nowIndicator: true,
        defaultView: window.defaultView,
        locale: jaLocale,
        header: header,
        selectable: window.userAllowedToEdit,
        eventDurationEditable: false,
        minTime: window.minTime,
        maxTime: window.maxTime,
        firstDay: window.firstDay,
        refetchResourcesOnNavigate: true,
        displayEventEnd: true,
        editable: window.userAllowedToEdit,
        height: function () {
            var height
            if (window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                height = 'auto'
            } else {
                height = (window.innerHeight - 160)
            }
            return height
        },
        views: {
            'timeGrid': {
                slotLabelFormat: { hour: 'numeric', minute: '2-digit' },
            },
            'timeGridDay': {
                titleFormat: {year: 'numeric', month: 'long', day: 'numeric', weekday: 'short'},
                columnHeaderFormat: {month: 'numeric', day: 'numeric', weekday: 'short'}
            },
            'dayGrid': {
                slotLabelFormat: { day: 'numeric' },
                eventTimeFormat: {omitZeroMinute: false, hour: 'numeric', minute: '2-digit'}
            },
            'resourceTimeGridDay': {
                resourceLabelText: window.resourceLabel,
                slotLabelFormat: {hour:  'numeric', minute: '2-digit'},
                eventTimeFormat: {omitZeroMinute: false, hour: 'numeric', minute: '2-digit'},
                titleFormat: {year: 'numeric', month: 'long', day: 'numeric', weekday: 'short'}
            },
            'resourceTimelineWeek': {
                slotDuration: { days: 1 },
                resourceAreaWidth: 100,
                resourceLabelText: window.resourceLabel,
                eventTimeFormat: {omitZeroMinute: false, hour: 'numeric', minute: '2-digit'},
                eventLimit: 6
            },
            'listDay': {
                titleFormat: {month: 'long', day: 'numeric', weekday: 'short'}
            }
        },
        buttonText: {
            listDay: '日'
        },
        listDayFormat: {month: 'long', day: 'numeric', weekday: 'short'},
        noEventsMessage: 'サービスがありません',


        viewSkeletonRender: function (info) {
            drawHourMarks()
            makeTimeAxisPrintFriendly()
        },

        resourceRender: function(renderInfo) {

            if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                var resourceLength = window.fullCalendar.getResources().length
                var calendarContainer = document.getElementsByClassName('fc-view')
                var maxLength = window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches ? 7 : 11
                if (renderInfo.view.type === 'resourceTimeGridDay') {
                    if (resourceLength >= maxLength) {
                        var parent = document.getElementsByClassName('fc-view-container')
                        var newWidth = parent[0].offsetWidth + 35 * (resourceLength - 7)
                        calendarContainer[0].style.width = `${newWidth}px`
                    } else {
                        calendarContainer[0].style.width = '100%'
                    }
                } else if (renderInfo.view.type === 'resourceTimelineWeek' && window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches) {
                    calendarContainer[0].style.width = '600px'
                }
            }
        },

        dayRender: function (info) {
            let holidays = JSON.parse(window.holidays);
            if (holidays.length > 0) {
                let dates = [];
                for (let holidayObject of holidays) {
                    dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"))
                }

                if (dates.indexOf(moment(info.date).format('YYYY-MM-DD')) > -1) {
                    let day_number = $("[data-date = " + moment(info.date).format('YYYY-MM-DD') + "] > span");
                    day_number.css('color', '#ff304f')
                }
            }

            if (info.view.type !== 'dayGridMonth') {
                $('.fc-center').addClass('no-print')
            } else {
                $('.fc-center').removeClass('no-print')
            }

            let selectedItem = document.getElementById(`${window.currentResourceType || window.defaultResourceType}_${window.currentResourceId || window.defaultResourceId}`)
            updatePrintInfoAndLayout(selectedItem)
        },

        resources: function (fetchInfo, successCallback, failureCallback) {
            if (window.resourceUrl) {
                let connector = window.resourceUrl.indexOf('?') === -1 ? '?' : '&'
                let url = `${window.resourceUrl}${connector}start=${moment(fetchInfo.start).format('YYYY-MM-DD HH:mm')}&end=${moment(fetchInfo.end).format('YYYY-MM-DD HH:mm')}`
                $.getScript(url).then(data => successCallback($.parseJSON(data)))
            }
        },

        eventSources: [
            {
                events: function (fetchInfo, successCallback, failureCallback) {
                    let url1 = window.eventsUrl1
                    let data = {};

                    data['start'] = moment(fetchInfo.start).format('YYYY-MM-DD HH:mm')
                    data['end'] = moment(fetchInfo.end).format('YYYY-MM-DD HH:mm')
                    if ((window.currentResourceId && window.currentResourceId !== 'all') || (!window.currentResourceId && window.defaultResourceId !== 'all')) {
                        let resourceArgument = `${window.currentResourceType || window.defaultResourceType}_id`
                        data[resourceArgument] = window.currentResourceId || window.defaultResourceId

                        if (fetchInfo.end - fetchInfo.start === 86400000 && window.defaultResourceType !== 'team' && window.currentResourceType !== 'team') {
                            data['list_view'] = true
                        }
                    }


                    $.ajax({
                        url: url1,
                        type: 'GET',
                        data: data
                    }).then(data => successCallback(data))
                },
                id: 'url1'
            },
            {
                events: function (fetchInfo, successCallback, failureCallback) {
                    let url2 = window.eventsUrl2

                    if (url2) {
                        let data = {}
                        data['start'] = moment(fetchInfo.start).format('YYYY-MM-DD HH:mm')
                        data['end'] = moment(fetchInfo.end).format('YYYY-MM-DD HH:mm')
                        if ((window.currentResourceId && window.currentResourceId !== 'all') || (!window.currentResourceId && window.defaultResourceId !== 'all')) {
                            let resourceArgument = `${window.currentResourceType || window.defaultResourceType}_id`
                            data[resourceArgument] = window.currentResourceId || window.defaultResourceId
                        }
                        $.ajax({
                            url: url2,
                            type: 'GET',
                            data: data
                        }).then(data => successCallback(data))
                    } else {
                        successCallback([])
                    }
                },
                id: 'url2'
            }
        ],

        eventDragStart: function (info) {
            window.eventDragging = true;
        },

        eventDragStop: function (info) {
            window.eventDragging = false;
        },

        datesRender: function(info) {
            responsiveHeader(info.view)

            restyleMobileCalendarDates(info.view)
        },

        eventPositioned: function(info) {
            if (window.eventDragging) {
                return
            }

            if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                var titleTag = info.el.querySelector('.fc-title')
                if (titleTag) {
                    titleTag.classList.add('title-responsive')
                }
                if (info.view.type === 'resourceTimeGridDay') {
                    var timeTag = info.el.querySelector('.fc-time')
                    if (timeTag) {
                        var newDate = timeTag.innerHTML.match(/[^ -]*/i)[0]
                        timeTag.innerHTML = newDate 
                        timeTag.classList.add('fc-time-responsive')
                    }
                } else if (['timeGridDay', 'resourceTimelineWeek'].includes(info.view.type)) {
                    var timeTag = info.el.querySelector('.fc-time')
                    if (timeTag) {
                        timeTag.classList.add('fc-time-responsive')
                    }
                } 
                if (['dayGridMonth', 'timeGridWeek'].includes(info.view.type)) {
                    var timeTag = info.el.querySelector('.fc-time')
                    if (timeTag) {
                        var startTime = timeTag.innerHTML.match(/[^ -]*/i)[0]
                        var endTime = timeTag.innerHTML.substr(timeTag.innerHTML.indexOf('-'))
                        timeTag.innerHTML = `${startTime}<span class="responsive-landscape-only">${endTime}</span>`
                        timeTag.classList.add('fc-time-responsive')
                    }
                }
            }

            if (info.event.extendedProps.cancelled) {
                info.el.style.backgroundImage = 'repeating-linear-gradient(45deg, #FFBFBF, #FFBFBF 5px, #FF8484 5px, #FF8484 10px)'
                info.el.classList.add('colibri-cancelled')
            } else if (info.event.extendedProps.edit_requested) {
                info.el.style.backgroundImage = 'repeating-linear-gradient(45deg, #C8F6DF, #C8F6DF 5px, #99E6BF 5px, #99E6BF 10px)'
                info.el.classList.add('colibri-edit-requested')
            }

            if (['recurring_appointment', 'appointment'].includes(info.event.extendedProps.eventType)) {
                if (window.currentResourceType === 'patient' || (!window.currentResourceType && window.defaultResourceId === 'patient')) {
                    let title = info.event.extendedProps.nurse ? info.event.extendedProps.nurse.name : ''
                    if (info.event.title !== title) {
                        info.event.setProp('title', title)
                    }
                } else {
                    let title = info.event.extendedProps.patient ? `${info.event.extendedProps.patient.name}様` : ''
                    if (info.event.title !== title) {
                        info.event.setProp('title', title)
                    }
                }
            } else if (info.event.extendedProps.eventType === 'private_event') {
                if (window.currentResourceType === 'patient' || (!window.currentResourceType && window.defaultResourceId === 'patient')) {
                    let title = (info.event.extendedProps.nurse && info.event.extendedProps.nurse.name) ? `${info.event.extendedProps.nurse.name}: ${info.event.extendedProps.serviceType}` : info.event.title 
                    if (info.event.title !== title) {
                        info.event.setProp('title', title)
                    }
                } else {
                    let title = (info.event.extendedProps.patient && info.event.extendedProps.patient.name) ? `${info.event.extendedProps.patient.name}様: ${info.event.extendedProps.serviceType}` : info.event.title 
                    if (info.event.title !== title) {
                        info.event.setProp('title', title)
                    }
                }
            }

            if (info.view.type == 'listDay' && (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches)) {
                let eventTime = info.el.getElementsByClassName('fc-list-item-time')[0].innerText
                let eventTitle = info.event.extendedProps.cancelled ? `${info.event.title}　（キャンセル）` : info.event.title
                let newHtml = `<tr>
                      <div class="colibri-fc-list" style="background-color:#EFF2F5">
                        <div class="colibri-fc-list-time">${eventTime}</div>
                        <div class="colibri-fc-list-title">${eventTitle}</div>
                      </div>
                    </tr>`
                info.el.innerHTML = newHtml 
                if (info.event.extendedProps.description) {
                    let pTag = `<p class="colibri-list-subtitle">サ責からの指示</p><p class="colibri-fc-list-body">${info.event.extendedProps.description}</p>`
                    info.el.firstElementChild.insertAdjacentHTML('beforeend', pTag)
                }
                if (info.event.extendedProps.previous_report_comment) {
                    let pTag = `<p class="colibri-list-subtitle">前回のサービス内容</p><p class="colibri-fc-list-body">${info.event.extendedProps.previous_report_comment}</p>`
                    info.el.firstElementChild.insertAdjacentHTML('beforeend', pTag)
                }
            } 

            if (!window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches && !window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                if (typeof(info.event) !== 'undefined') {
                    let popoverTitle = info.event.extendedProps.serviceType || ''
                
                    let popoverContent
                    if (info.event.extendedProps.patient && info.event.extendedProps.patient.address) {
                        popoverContent = `${info.event.extendedProps.patient.address}<br/>${info.event.extendedProps.description}`
                    } else {
                        popoverContent = info.event.extendedProps.description
                    }
                    
                    $(info.el).popover({
                        html: true,
                        title: popoverTitle,
                        content: popoverContent,
                        placement: 'top',
                        container: 'body',
                        trigger: 'manual'
                    }).on('mouseenter', function () {
                        if (window.popoverFocusAllowed) {
                            window.popoverFocusAllowed = false
                            var _this = this;
                            $(_this).popover('show');
                            $('.popover').on('mouseleave', function () {
                                $(_this).popover('hide');
                            });
                        }
                    }).on('mouseleave', function () {
                        var _this = this
                        var condition = $('.popover-body').overflownY();
                        if (condition) {
                            setTimeout(function () {
                                if (!$('.popover:hover').length) {
                                    $(_this).popover('hide');
                                }
                            }, 300);
                        } else {
                            $(_this).popover('hide')
                        }
                        window.popoverFocusAllowed = true
                    });
                }

            }
        },

        eventClick: function (info) {            
            if (info.event.extendedProps.eventType === 'appointment' && (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches)) {
                $.getScript(`/appointments/${info.event.extendedProps.eventId}.js`)
            } else {
                if (!window.userAllowedToEdit) {
                    return
                }
                let dateClicked = dateFormatter.format(info.event.start)
                $.getScript(`${window.planningPath}/${info.event.extendedProps.eventType}s/${info.event.extendedProps.eventId}/edit.js?date=${dateClicked}`, function(){
                    let screenStart = moment(info.view.activeStart).format('YYYY-MM-DD HH:mm')
                    let screenEnd = moment(info.view.activeEnd).format('YYYY-MM-DD HH:mm')
                    let dateClicked = moment(info.event.start).format('YYYY-MM-DD HH:mm')
                    if (info.event.extendedProps.eventType === 'recurring_appointment') {
                        terminateRecurringAppointment(dateClicked, screenStart, screenEnd)
                    }
                    if (['recurring_appointment', 'wished_slot'].includes(info.event.extendedProps.eventType)) {
                        setHiddenStartAndEndFields(screenStart, screenEnd)
                    }
                });
            }
        },

        select: function (info) {
            let selectEnd = info.end
            let selectStart = info.start
            let screenStart = moment(info.view.activeStart).format('YYYY-MM-DD HH:mm')
            let screenEnd = moment(info.view.activeEnd).format('YYYY-MM-DD HH:mm')
            if (selectEnd - selectStart <= 900000) {
                selectEnd.setMinutes(selectStart.getMinutes() + 30)
            }
            $.getScript(window.selectActionUrl, function () {
                let resourceType

                if (window.selectActionUrl.includes('/recurring_appointments/new')) {
                    setRecurringAppointmentRange(selectStart, selectEnd, info.view);
                    setHiddenStartAndEndFields(screenStart, screenEnd)
                    resourceType = 'recurring_appointment'
                } else if (window.selectActionUrl.includes('/wished_slots/new')) {
                    setWishedSlotRange(selectStart, selectEnd, info.view)
                    setHiddenStartAndEndFields(screenStart, screenEnd)
                    resourceType = 'wished_slot'
                } else if (window.selectActionUrl.includes('/calendar_events/new')) {
                    setAppointmentRange(selectStart, selectEnd, info.view);
                    setPrivateEventRange(selectStart, selectEnd, info.view);
                    resourceType = 'calendar_event'
                }
                if (info.resource) {
                    setResource(resourceType, info.resource)
                }
                if (resourceType === 'recurring_appointment') {
                    recurringAppointmentSelectizeNursePatient()
                } else if (resourceType === 'wished_slot') {
                    wishedSlotsSelectize()
                } else if (resourceType === 'calendar_event') {
                    appointmentSelectizeNursePatient();
                    privateEventSelectizeNursePatient();
                }
            });

            this.unselect()
        },

        eventDrop: function (eventDropInfo) {
            $(".popover").remove()

            if (window.masterCalendar === 'true') {
                masterDragOptions(eventDropInfo)
            } else {
                nonMasterDragOptions(eventDropInfo)
            }
        }
    })

    return calendar
}

let dateFormatter = new Intl.DateTimeFormat('sv-SE')

let drawHourMarks = () => {
    $('tr*[data-time="09:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="12:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="15:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="18:00:00"]').addClass('thick-calendar-line');
}

let makeTimeAxisPrintFriendly = () => {
    $('tr[data-time] > td > span').addClass('bolder-calendar-time-axis')
}

let setWishedSlotRange = (start, end, view) => {
    $('#wished_slot_anchor_1i').val(moment(start).format('YYYY'));
    $('#wished_slot_anchor_2i').val(moment(start).format('M'));
    $('#wished_slot_anchor_3i').val(moment(start).format('D'));
    $('#wished_slot_starts_at_4i').val(moment(start).format('YYYY'));
    $('#wished_slot_starts_at_2i').val(moment(start).format('M'));
    $('#wished_slot_starts_at_3i').val(moment(start).format('D'));
    $('#wished_slot_starts_at_4i').val(moment(start).format('HH'));
    $('#wished_slot_starts_at_5i').val(moment(start).format('mm'));
    $('#wished_slot_ends_at_1i').val(moment(end).format('YYYY'));
    $('#wished_slot_ends_at_2i').val(moment(end).format('M'));
    $('#wished_slot_ends_at_3i').val(moment(end).format('D'));
    $('#wished_slot_ends_at_4i').val(moment(end).format('HH'));
    $('#wished_slot_ends_at_5i').val(moment(end).format('mm'));
    $('#wished_slot_end_day_1i').val(moment(end).format('YYYY'));
    $('#wished_slot_end_day_2i').val(moment(end).format('M'));
    $('#wished_slot_end_day_3i').val(moment(end).format('D'));
    let nurseId = window.currentResourceId || window.defaultResourceId
    $("#wished_slot_nurse_id").val(nurseId);
}

let setPrivateEventRange = (start, end, view) => {
    $('#private_event_starts_at_1i').val(moment(start).format('Y'));
    $('#private_event_starts_at_2i').val(moment(start).format('M'));
    $('#private_event_starts_at_3i').val(moment(start).format('D'));
    $('#private_event_starts_at_4i').val(moment(start).format('HH'));
    $('#private_event_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'resourceTimelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
        $('#private_event_ends_at_1i').val(moment(start).format('Y'));
        $('#private_event_ends_at_2i').val(moment(start).format('M'));
        $('#private_event_ends_at_3i').val(moment(start).format('D'));
        $('#private_event_ends_at_4i').val('23');
        $('#private_event_ends_at_5i').val('00');
    } else {
        $('#private_event_ends_at_1i').val(moment(end).format('Y'));
        $('#private_event_ends_at_2i').val(moment(end).format('M'));
        $('#private_event_ends_at_3i').val(moment(end).format('D'));
        $('#private_event_ends_at_4i').val(moment(end).format('HH'));
        $('#private_event_ends_at_5i').val(moment(end).format('mm'));
    }

    let individualView = (window.currentResourceType && (window.currentResourceType !== 'team' && window.currentResourceId !== 'all')) || (!window.currentResourceType && (window.defaultResourceType !== 'team' && window.defaultResourceId !== 'all'))

    if (individualView) {
        $(`#private_event_${window.currentResourceType || window.defaultResourceType}_id`).val(window.currentResourceId || window.defaultResourceId);
    } 

}

let setAppointmentRange = (start, end, view) => {
    $('#appointment_starts_at_1i').val(moment(start).format('YYYY'));
    $('#appointment_starts_at_2i').val(moment(start).format('M'));
    $('#appointment_starts_at_3i').val(moment(start).format('D'));
    $('#appointment_starts_at_4i').val(moment(start).format('HH'));
    $('#appointment_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'resourceTimelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
        $('#appointment_ends_at_1i').val(moment(start).format('YYYY'));
        $('#appointment_ends_at_2i').val(moment(start).format('M'));
        $('#appointment_ends_at_3i').val(moment(start).format('D'));
        $('#appointment_ends_at_4i').val('23');
        $('#appointment_ends_at_5i').val('00');
    } else {
        $('#appointment_ends_at_1i').val(moment(end).format('YYYY'));
        $('#appointment_ends_at_2i').val(moment(end).format('M'));
        $('#appointment_ends_at_3i').val(moment(end).format('D'));
        $('#appointment_ends_at_4i').val(moment(end).format('HH'));
        $('#appointment_ends_at_5i').val(moment(end).format('mm'));
    }

    let individualView = (window.currentResourceType && (window.currentResourceType !== 'team' && window.currentResourceId !== 'all')) || (!window.currentResourceType && (window.defaultResourceType !== 'team' && window.defaultResourceId !== 'all'))

    if (individualView) {
        $(`#appointment_${window.currentResourceType || window.defaultResourceType}_id`).val(window.currentResourceId || window.defaultResourceId);
    }
}

let setRecurringAppointmentRange = (start, end, view) => {
    $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
    $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
    $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
    $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
    $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'resourceTimelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
        $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
        $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
        $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
        $('#recurring_appointment_ends_at_4i').val('23');
        $('#recurring_appointment_ends_at_5i').val('00');
    } else {
        $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
        $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
        $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
        $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
        $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
    }

    let individualView = (window.currentResourceType && (window.currentResourceType !== 'team' && window.currentResourceId !== 'all')) || (!window.currentResourceType && (window.defaultResourceType !== 'team' && window.defaultResourceId !== 'all'))

    if (individualView) {
        $(`#recurring_appointment_${window.currentResourceType || window.defaultResourceType}_id`).val(window.currentResourceId || window.defaultResourceId);
    } 

}

let restyleMobileCalendarDates = (view) => {
    if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
        var fcCenter = document.getElementsByClassName('fc-center')[0]
        if (fcCenter) {
            var title = fcCenter.childNodes[0]
            var fullDate = title.textContent
            var date
            if (view.type === 'resourceTimeGridDay' || view.type === 'dayGridMonth') {
                if (fullDate.length >= 9) {
                    date = fullDate.substr(5)
                    title.innerText = date
                }
                title.style.display = 'block'
            } else if (view.type === 'listDay') {
                $('#no-appointments-date').html(fullDate)
                title.style.display = 'none'
            } else {
                title.style.display = 'none'
            }
        }
        if (view.type == 'dayGridMonth') {
            $('.fc-today-button').hide()
        }
    }
}

let responsiveHeader = (view) => {
    if (view.type === 'timeGridWeek') {
        if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
            let dayHeaders = $('.fc-day-header')
            if (dayHeaders) {
                dayHeaders.each(function(index, element) {
                    let newDate = `${moment(element.dataset.date).locale('ja').format('dd')}<br/>${moment(element.dataset.date).format('M/D')}`
                    element.innerHTML = newDate
                })

            }
        }
    }
}

let setResource = (eventType, resource) => {
    if (eventType === 'calendar_event') {
        $(`#appointment_${resource.extendedProps.model_name}_id`).val(resource.extendedProps.record_id)
        $(`#private_event_${resource.extendedProps.model_name}_id`).val(resource.extendedProps.record_id)
    } else {
        $(`#${eventType}_${resource.extendedProps.model_name}_id`).val(resource.extendedProps.record_id)
    }

}

let setHiddenStartAndEndFields = (start, end) => {
    $('#start').val(start)
    $('#end').val(end)
}


let wishedSlotsSelectize = () => {
    $('#wished_slot_nurse_id').selectize()
}

let terminateRecurringAppointment = (date, start, end) => {

    $('#recurring-appointment-terminate').text(moment(date).format('M月DD日') + '以降削除');
    let data = {
        t_date: moment(date).format('YYYY-MM-DD HH:mm'),
        start: moment(start).format('YYYY-MM-DD HH:mm'),
        end: moment(end).format('YYYY-MM-DD HH:mm')
    };
    $('#recurring-appointment-terminate').click(function () {
        let message = confirm('サービスの繰り返しが' + moment(date).format('M月DD日') + '以降削除されます')
        if (message) {
            $.ajax({
                url: $(this).data('terminate-url'),
                data: data,
                type: 'PATCH'
            })
        }
    })
} 

let handleAppointmentOverlapRevert = (revertFunc) => {
    $('#nurse-revert-overlap').off()
    $('#close-nurse-overlap-modal').off()

    $('#nurse-revert-overlap').one('click', function () {
        revertFunc()
    })
    $('#close-nurse-overlap-modal').one('click', function () {
        revertFunc()
    })
}

let updateCalendarHeader = () => {
    if (window.currentResourceType === 'team' ||(window.currentResourceType === 'nurse' && window.currentResourceId === 'all') || (window.currentResourceType === 'patient' && window.currentResourceId === 'all')) {
        window.fullCalendar.setOption('header', resourceHeader)
    } else {
        if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
            window.fullCalendar.setOption('header', mobileHeader)
        } else {
            window.fullCalendar.setOption('header', header)
        }
    }
}

let toggleResourceView = () => {
    let currentView = window.fullCalendar.view
    if (window.currentResourceType === 'team' || (window.currentResourceType === 'nurse' && window.currentResourceId === 'all') || (window.currentResourceType === 'patient' && window.currentResourceId === 'all')) {
        if (['listDay', 'timeGridDay', 'timeGridWeek', 'dayGridMonth'].includes(currentView.type)) {
            window.fullCalendar.changeView(window.defaultResourceView)
            drawHourMarks()
        }
    } else {
        if (['resourceTimeGridDay', 'resourceTimelineWeek'].includes(currentView.type)) {
            window.fullCalendar.changeView(window.defaultView)
            drawHourMarks()
        }
    }
}


let removeEvents = () => {
    window.fullCalendar.batchRendering(function(){
        let events = window.fullCalendar.getEvents()

        for (let event of events) {
            event.remove()
        }
    })

    return
}

let updatePayableUrl = () => {
    if (!window.userHasRestrictedAccess) {
        let baseUrl = window.location.href 
        if (baseUrl.includes('/master')) {
            baseUrl = baseUrl.replace('/master', '')
        }
        let targetUrl
        if (window.currentResourceType === 'team' || window.currentResourceId !== 'all') {
            targetUrl = `${baseUrl}/${window.currentResourceType}s/${window.currentResourceId}/payable?m=${window.currentMonth}&y=${window.currentYear}`
        } else if (window.currentResourceType === 'nurse' && window.currentResourceId === 'all') {
            targetUrl = `${baseUrl}/all_nurses_payable?m=${window.currentMonth}&y=${window.currentYear}`
        } else if (window.currentResourceType === 'patient' && window.currentResourceId === 'all') {
            targetUrl = `${baseUrl}/all_patients_payable?m=${window.currentMonth}&y=${window.currentYear}`
        }
    
        document.getElementById('go-to-payable').dataset.url = targetUrl
    }
}

let toggleNurseFilterButton = () => {
    let nurseFilterWrapper = document.getElementById('nurse_filter_wrapper')
    if (nurseFilterWrapper) {
        let allNurseView = (window.currentResourceType === 'nurse' && window.currentResourceId === 'all') || (!window.currentResourceType && window.defaultResourceType === 'nurse' && window.defaultResourceId === 'all')
        if (allNurseView) {
            nurseFilterWrapper.style.display = 'block'
        } else {
            nurseFilterWrapper.style.display = 'none'
        }
    }
}



let toggleWishedSlotsAndPrintAvailabilitiesButton = () => {
    if (window.masterCalendar === 'true') {
        let wishedSlotsButton = document.getElementById('wished-slots-toggle-switch') 
        let individualNurse = (!window.currentResourceType && window.defaultResourceType === 'nurse' && window.defaultResourceId !== 'all') || (window.currentResourceType === 'nurse' && window.currentResourceId !== 'all')
        let printAvailabilitiesButton = document.getElementById('availabilities-print')
        document.getElementById('toggle-switch-wished-slots').style.display = 'none'
        document.getElementById('toggle-switch-recurring-appointments').style.display = 'block'
        if (individualNurse) {
            wishedSlotsButton.style.display = 'block'
            printAvailabilitiesButton.style.display = 'none'
        } else {
            wishedSlotsButton.style.display = 'none'
            printAvailabilitiesButton.style.display = 'none'
            if ((window.currentResourceId === 'all' & window.currentResourceType === 'nurse') || (!window.currentResourceId && window.defaultResourceId === 'all' && window.defaultResourceType === 'nurse')) {
                printAvailabilitiesButton.style.display = 'block'
            }
        }
    }
}

let updateSelectize = () => {
    if ($('#nurse_resource_filter').length > 0) {
        $('#nurse_resource_filter').selectize()[0].selectize.clear()
    }
}


let updateMasterEventsUrl = () => {
    if (window.masterCalendar === 'true') {
        if (window.currentResourceType === 'patient' || (!window.currentResourceType && window.defaultResourceType === 'patient')) {
            window.eventsUrl1 = window.recurringAppointmentsUrl
            window.eventsUrl2 = ''
        } else {
            window.eventsUrl1 = window.recurringAppointmentsUrl
            window.eventsUrl2 = window.wishedSlotsUrl + '?background=true'
        }
    }
}

let updatePrintOptions = () => {
    if (window.masterCalendar === 'true') {
        if (window.currentResourceType === 'patient' || (!window.currentResourceType && window.defaultResourceType === 'patient')) {
            window.printDates = window.printPatientDates
        } else {
            window.printDates = window.printNurseDates
        }
    }
}

let humanizeFrequency = (frequency) => {
    switch (frequency) {
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

let masterDragOptions = (eventDropInfo) => {
    let frequency = humanizeFrequency(eventDropInfo.event.extendedProps.frequency);
    let newAppointmentDetails = `${moment(eventDropInfo.event.start).locale('ja').format('[(]dd[)]')}${frequency} ${moment(eventDropInfo.event.start).locale('ja').format('LT')} ~ ${moment(eventDropInfo.event.end).locale('ja').format('LT')}`
    let minutes = moment.duration(eventDropInfo.delta).asMinutes();
    let previousStart = moment(eventDropInfo.event.start).subtract(minutes, "minutes");
    let startTime = moment(eventDropInfo.view.activeStart).format('YYYY-MM-DD')
    let endTime = moment(eventDropInfo.view.activeEnd).format('YYYY-MM-DD')
    let newNurseId;
    let newPatientId;
    let newPatientName;
    let newNurseName;

    if ((eventDropInfo.newResource === eventDropInfo.oldResource) || (!eventDropInfo.newResource)) {
        newNurseId = eventDropInfo.event.extendedProps.nurse_id
        newNurseName = eventDropInfo.event.extendedProps.nurse.name
        newPatientId = eventDropInfo.event.extendedProps.patient_id
        newPatientName = eventDropInfo.event.extendedProps.patient.name 
    } else {
        if (eventDropInfo.newResource.extendedProps.model_name === 'patient') {
            newPatientId = eventDropInfo.newResource.extendedProps.record_id
            newNurseId = eventDropInfo.event.extendedProps.nurse_id
            newPatientName = eventDropInfo.newResource.title
            newNurseName = eventDropInfo.event.extendedProps.nurse.name 
        } else if (eventDropInfo.newResource.extendedProps.model_name === 'nurse') {
            newNurseId = eventDropInfo.newResource.extendedProps.record_id
            newPatientId = eventDropInfo.event.extendedProps.patient_id
            newNurseName = eventDropInfo.newResource.title
            newPatientName = eventDropInfo.event.extendedProps.patient.name
        }
    }

    $('#drag-drop-master-content').html(`<p>従業員：${newNurseName} / ${window.clientResourceName} : ${newPatientName} </p><p>${newAppointmentDetails}</p>`)

    $('#drag-drop-master').modal({ backdrop: 'static' })

    /* clearing previous click actions */
    $('.close-drag-drop-modal').off('click')
    $('#master-drag-copy').off('click')
    $('#master-drag-move').off('click')


    $('.close-drag-drop-modal').click(function () {
        eventDropInfo.revert()
        $('.modal').modal('hide');
        $('.modal-backdrop').remove();
    })
    
    $('#master-drag-copy').one('click', function () {
        $('.modal').modal('hide');
        $('.modal-backdrop').remove();
        $.ajax({
            url: `${window.planningPath}/recurring_appointments.js?start=${startTime}&end=${endTime}`,
            type: 'POST',
            data: {
                recurring_appointment: {
                    nurse_id: newNurseId,
                    patient_id: newPatientId,
                    frequency: eventDropInfo.event.extendedProps.frequency,
                    service_id: eventDropInfo.event.extendedProps.service_id,
                    color: eventDropInfo.event.backgroundColor,
                    anchor: moment(eventDropInfo.event.start).format('YYYY-MM-DD'),
                    end_day: moment(eventDropInfo.event.end).format('YYYY-MM-DD'),
                    starts_at: moment(eventDropInfo.event.start).format('YYYY-MM-DD HH:mm'),
                    ends_at: moment(eventDropInfo.event.end).format('YYYY-MM-DD HH:mm')
                },
            },
            success: function (data) {
                $(".popover").remove();
            }
        });
        eventDropInfo.revert();
    })
    $('#master-drag-move').one('click', function () {
        $.ajax({
            url: `${window.planningPath}/recurring_appointments/${eventDropInfo.event.extendedProps.eventId}.js?start=${startTime}&end=${endTime}`,
            type: 'PATCH',
            data: {
                recurring_appointment: {
                    starts_at: moment(eventDropInfo.event.start).format('YYYY-MM-DD HH:mm'),
                    ends_at: moment(eventDropInfo.event.end).format('YYYY-MM-DD HH:mm'),
                    anchor: moment(eventDropInfo.event.start).format('YYYY-MM-DD'),
                    end_day: moment(eventDropInfo.event.end).format('YYYY-MM-DD'),
                    nurse_id: newNurseId,
                    patient_id: newPatientId,
                    editing_occurrences_after: previousStart.format('YYYY-MM-DD'),
                    synchronize_appointments: 1,
                    updating_from_drag_and_drop: 1
                }
            },
            success: function(){
                $('.modal').modal('hide');
                $('.modal-backdrop').remove();
            }
        })
        $(".popover").remove();
    })
}

let nonMasterDragOptions = (eventDropInfo) => {

    let newPatientId
    let newNurseId
    let newResourceType
    let newResourceTitle

    if ((eventDropInfo.newResource === eventDropInfo.oldResource) || (!eventDropInfo.newResource)) {
        newPatientId = eventDropInfo.event.extendedProps.patient_id
        newNurseId = eventDropInfo.event.extendedProps.nurse_id
    } else {
        if (eventDropInfo.newResource.extendedProps.model_name === 'nurse') {
            newPatientId = eventDropInfo.newResource.extendedProps.patient_id
            newNurseId = eventDropInfo.newResource.extendedProps.record_id 

            if (eventDropInfo.oldResource.title === eventDropInfo.event.extendedProps.nurse.name) {
                newResourceType = '従業員'
            } else if (eventDropInfo.event.extendedProps.second_nurse && eventDropInfo.oldResource.title === eventDropInfo.event.extendedProps.second_nurse.name) {
                newResourceType = '同行従業員'
            } else {
                newResourceType = ''
            }
            newResourceTitle = eventDropInfo.newResource.title
        } else if (eventDropInfo.newResource.extendedProps.model_name === 'patient') {
            newPatientId = eventDropInfo.newResource.extendedProps.record_id
            newNurseId = eventDropInfo.event.extendedProps.nurse_id
            newResourceType = '利用者'
            newResourceTitle = eventDropInfo.newResource.title
        }
    }

    if (window.editConfirmRequested) {
        showDragDropConfirm(eventDropInfo, newNurseId, newPatientId, newResourceType, newResourceTitle)
    } else {
        updateAppointmentFromDragDrop(eventDropInfo, newResourceType, newNurseId, newPatientId)
    }
}

let showDragDropConfirm = (eventDropInfo, newNurseId, newPatientId, newResourceType, newResourceTitle) => {
    let minutes = moment.duration(eventDropInfo.delta).asMinutes();
    let previous_start = moment(eventDropInfo.event.start).subtract(minutes, "minutes");
    let previous_end = moment(eventDropInfo.event.end).subtract(minutes, "minutes");
    let previousAppointment = `${previous_start.locale('ja').format('M[月]D[日][(]dd[)] LT')} ~ ${previous_end.locale('ja').format('LT')}`
    let newAppointment = `${moment(eventDropInfo.event.start).locale('ja').format('M[月]D[日][(]dd[)] LT')} ~ ${moment(eventDropInfo.event.end).locale('ja').format('LT')}`
    let nurse_name = eventDropInfo.event.extendedProps.nurse.name;
    let second_nurse_name
    if (eventDropInfo.event.extendedProps.second_nurse) {
        second_nurse_name = eventDropInfo.event.extendedProps.second_nurse.name;
    }
    let patient_name = eventDropInfo.event.extendedProps.patient.name
    let changeInResource
    let secondNurseText = ''

    if (second_nurse_name) {
        secondNurseText = ` / 同行従業員：${second_nurse_name}`
    }


    if (newResourceTitle && newResourceType) {
        changeInResource = `<p>新規${newResourceType}: ${newResourceTitle}</p>`
    } else {
        changeInResource = ''
    }

    $('#drag-drop-content').html(`<p>従業員：${nurse_name}${secondNurseText}</p> <p>${window.clientResourceName}: ${patient_name}</p>${changeInResource}<p>${previousAppointment} >> </p><p>${newAppointment}</p>`)

    $('#drag-drop-modal').modal()

    /* need to unbind the click actions before attaching revert and save */ 
    $('.close-drag-drop-modal').off('click')
    $('#drag-drop-save').off('click')

    $('.close-drag-drop-modal').click(function () {
        eventDropInfo.revert()
        $('.modal').modal('hide');
        $('.modal-backdrop').remove();
    })

    $('#drag-drop-save').one('click', function () {
        updateAppointmentFromDragDrop(eventDropInfo, newResourceType, newNurseId, newPatientId)
    })
}

let updateAppointmentFromDragDrop = (eventDropInfo, newResourceType, newNurseId, newPatientId) => {
    let ajaxData;
    if (eventDropInfo.event.extendedProps.eventType === 'private_event') {
        ajaxData = {
            private_event: {
                starts_at: moment(eventDropInfo.event.start).format('YYYY-MM-DD HH:mm'),
                ends_at: moment(eventDropInfo.event.end).format('YYYY-MM-DD HH:mm'),
                nurse_id: newNurseId,
                patient_id: newPatientId
            }
        }
    } else if (eventDropInfo.event.extendedProps.eventType === 'appointment') {
        if (newResourceType === '同行従業員') {
            ajaxData = {
                appointment: {
                    starts_at: moment(eventDropInfo.event.start).format('YYYY-MM-DD HH:mm'),
                    ends_at: moment(eventDropInfo.event.end).format('YYYY-MM-DD HH:mm'),
                    second_nurse_id: newNurseId,
                    patient_id: newPatientId
                }
            }
        } else {
            ajaxData = {
                appointment: {
                    starts_at: moment(eventDropInfo.event.start).format('YYYY-MM-DD HH:mm'),
                    ends_at: moment(eventDropInfo.event.end).format('YYYY-MM-DD HH:mm'),
                    nurse_id: newNurseId,
                    patient_id: newPatientId
                }
            }
        }
    }
    handleAppointmentOverlapRevert(eventDropInfo.revert)
    $.ajax({
        url: `${window.planningPath}/${eventDropInfo.event.extendedProps.eventType}s/${eventDropInfo.event.extendedProps.eventId}.js`,
        type: 'PATCH',
        data: ajaxData,
        success: function () {
            $('.modal').modal('hide');
            $('.modal-backdrop').remove();
        }
    }).then(_ => handleAppointmentOverlapRevert(eventDropInfo.revert))
}

let toggleHeaderSubmenu = () => {
    if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
        let individualView = (window.currentResourceType && (window.currentResourceType !== 'team' && window.currentResourceId !== 'all')) || (!window.currentResourceType && (window.defaultResourceType !== 'team' && window.defaultResourceId !== 'all'))

        if (individualView) {
            $('#planning-header-submenu').show()
        } else {
            $('#planning-header-submenu').hide()
        }
    }
}

let switchBackToCalendarOnNavigate = () => {
    if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
        $('#resource-details-wrapper').remove()
        $('#calendar').show()
        $('.header-submenu-item').removeClass('header-submenu-item-selected')
        $('#header-calendar-button').addClass('header-submenu-item-selected')
    }   
}

let toggleNurseReminderButton = () => {
    if (window.masterCalendar === 'false') {
        let nurseResource = (window.currentResourceType === 'nurse' && window.currentResourceId !== 'all') || (!window.currentResourceType && window.defaultResourceType === 'nurse' && window.defaultResourceId !== 'all')
        if (nurseResource) {
            $('#new-reminder-email').show()
        } else {
            $('#new-reminder-email').hide()
        }
    }
}

let updatePrintInfoAndLayout = (selectedElement) => {
    let individualView = (window.currentResourceType && (window.currentResourceType !== 'team' && window.currentResourceId !== 'all')) || (!window.currentResourceType && (window.defaultResourceType !== 'team' && window.defaultResourceId !== 'all'))
    document.getElementById('resource-print-address').innerHTML = ''
    document.getElementById('resource-print-phone').innerHTML = ''
    document.getElementById('resource-print-description').innerHTML = ''
    if (individualView) {
        document.querySelector('style').textContent = ""
        if (window.printPatientInfo && selectedElement.dataset.resourceType === "patient" || (window.printNurseInfo && selectedElement.dataset.resourceType === 'nurse')) {
            let address = selectedElement.dataset.resourceAddress
            let phoneNumber = selectedElement.dataset.resourcePhone
            let description = selectedElement.dataset.resourceDescription

            if (address) {
                document.getElementById('resource-print-address').innerHTML = `<i class="glyphicon glyphicon-home"></i> ${address}`
            }
            if (phoneNumber) {
                document.getElementById('resource-print-phone').innerHTML = `<i class="glyphicon glyphicon-phone"></i> ${phoneNumber}`
            }
            if (description) {
                document.getElementById('resource-print-description').innerHTML = `備考： ${description}`
            }
        }
    } else {
        if (window.fullCalendar && window.fullCalendar.view && window.fullCalendar.view.type === 'resourceTimelineWeek') {
            document.querySelector('style').textContent = "@media print { @page { size: auto; margin: 10px 0px 10px 0px;}"
        } else {
            document.querySelector('style').textContent = ""
        }
    }
}

export default class extends Controller {

    static targets = [ 'resourceName' ]
    
    connect() {
        this.initializeResource()
        if (document.documentElement.hasAttribute('data-turbolinks-preview')) {
            return
        } else {
            this.renderCalendar()
        }
    }

    renderCalendar() {
        window.fullCalendar = createCalendar()
        this.initializeView()
        window.fullCalendar.render()  
    }

    initializeView() {
        if (window.currentResourceId && window.currentResourceType) {
            if (window.currentResourceType === 'team' || window.currentResourceId === 'all') {
                window.fullCalendar.changeView(window.defaultResourceView)
                window.fullCalendar.setOption('header', resourceHeader)
            } else {
                if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                    window.fullCalendar.setOption('header', mobileHeader)
                    if (!window.userAllowedToEdit || window.forceListView) {
                        window.fullCalendar.changeView('listDay')
                        window.defaultView = 'listDay'
                    }
                } else {
                    window.fullCalendar.changeView(window.defaultView)
                    window.fullCalendar.setOption('header', header)
                }
            }
        } else {
            if (window.defaultResourceType === 'team' || window.defaultResourceId === 'all') {
                window.fullCalendar.changeView(window.defaultResourceView)
                window.fullCalendar.setOption('header', resourceHeader)
            } else {
                if (window.matchMedia("(orientation: portrait) and (max-width: 760px)").matches || window.matchMedia("(orientation: landscape) and (max-width: 900px)").matches) {
                    window.fullCalendar.setOption('header', mobileHeader)
                    if (!window.userAllowedToEdit || window.forceListView) {
                        window.fullCalendar.changeView('listDay')
                        window.defaultView = 'listDay'
                    }
                } else {
                    window.fullCalendar.changeView(window.defaultView)
                    window.fullCalendar.setOption('header', header)
                }
            }
        }
    }

    initializeResource() {
        let resourceType = window.currentResourceType || window.defaultResourceType || 'nurse'
        let resourceId = window.currentResourceId || window.defaultResourceId || 'all'

        if (resourceType === 'patient') {
            document.getElementById('toggle-switch-nurses').style.display = 'none'
            document.getElementById('toggle-switch-patients').style.display = 'block'
            document.getElementById('patients-resource').classList.remove('hide-resource')
            document.getElementById('nurses-resource').classList.add('hide-resource')
        }

        let selectedItem = document.getElementById(`${resourceType}_${resourceId}`)

        selectedItem.classList.add('resource-selected')

        window.resourceUrl = selectedItem.dataset.fcResourceUrl

        this.resourceNameTarget.textContent = selectedItem.textContent

        this.toggleDetailsButton()
        this.toggleReportsButton()
        toggleNurseFilterButton()
        toggleWishedSlotsAndPrintAvailabilitiesButton()
        updateMasterEventsUrl()
        updatePrintOptions()
        toggleHeaderSubmenu()
        switchBackToCalendarOnNavigate()
        toggleNurseReminderButton()
        updatePrintInfoAndLayout(selectedItem)

        return
    }

    navigate(event) {
        let selectedEl = document.getElementsByClassName('resource-selected')
        for (let el of selectedEl) {
            el.classList.remove('resource-selected')
        }
        event.target.classList.add('resource-selected')
        
        window.currentResourceType = event.target.dataset.resourceType
        window.currentResourceId = event.target.dataset.resourceId
        window.resourceLabel = window.currentResourceType === 'patient' ? '利用者' : '従業員'
        removeEvents()
        switchBackToCalendarOnNavigate()
        
        updateCalendarHeader()
        toggleResourceView()

        window.resourceUrl = event.target.dataset.fcResourceUrl

        document.getElementById('resource-details-panel').style.display = 'none'

        updateSelectize()
        updatePayableUrl()
        updateMasterEventsUrl()
              
        window.fullCalendar.refetchResources()
        window.fullCalendar.refetchEvents()

        if (window.fullCalendar && window.fullCalendar.view) {
            restyleMobileCalendarDates(window.fullCalendar.view)
            responsiveHeader(window.fullCalendar.view)
        }

        this.updateResourceTitle(event)
        
        this.toggleDetailsButton()
        this.toggleReportsButton()
        toggleNurseFilterButton()
        toggleWishedSlotsAndPrintAvailabilitiesButton()
        updatePrintOptions()
        toggleHeaderSubmenu()
        toggleNurseReminderButton()
        updatePrintInfoAndLayout(event.target)

        return
    }

    updateResourceTitle(event) {
        if (event.target.dataset.resourceType === 'patient' && event.target.dataset.resourceId !== 'all') {
            this.resourceNameTarget.textContent = `${event.target.textContent.trim()}様`
        } else {
            this.resourceNameTarget.textContent = event.target.textContent
        }
    }

    toggleDetailsButton() {
        let detailsButton = document.getElementById('resource-details-button')
        if (window.currentResourceType === 'team' || window.currentResourceId === 'all' || (!window.currentResourceType && (window.defaultResourceType === 'team' || window.defaultResourceId === 'all'))) {
            detailsButton.style.display = 'none'
        } else {
            detailsButton.style.display = 'inline-block'
            if (window.currentResourceType && window.currentResourceId) {
                detailsButton.dataset.resourceUrl = `/${window.currentResourceType}s/${window.currentResourceId}.js`
            } else {
                detailsButton.dataset.resourceUrl = `/${window.defaultResourceType}s/${window.defaultResourceId}.js`
            }
        }
    }

    toggleReportsButton() {
        if (window.masterCalendar === 'false') {
            let reportsButton = document.getElementById('display-completion-reports')
            if (reportsButton) {
                if (window.currentResourceType === 'team' || window.currentResourceId === 'all' || (!window.currentResourceType && (window.defaultResourceType === 'team' || window.defaultResourceId === 'all'))) {
                    reportsButton.style.display = 'none'
                } else {
                    reportsButton.style.display = 'inline-block'
                }
            }
        }
    }



    disconnect() {
        window.fullCalendar.destroy()
    }
}