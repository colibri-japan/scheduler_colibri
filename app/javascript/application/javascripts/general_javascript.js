window.onclick = function(event) {
    if (!event.target.matches('.dropbtn')) {
        var dropdowns = document.getElementsByClassName("colibri-dropdown-content")
        var i;
        for (i = 0; i < dropdowns.length; i++) {
            var openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('dropdown-show')) {
                openDropdown.classList.remove('dropdown-show');
            }
        }
    }
}

window.initializeTooltips = function() {
    $('.colibri-tooltip').each(function () {
        $(this).popover({
            html: true,
            content: $(this).data('content'),
            trigger: 'hover'
        })
    })
}

window.navigateBackOnMobile = function() {
    if ($('.activity_back_button').length > 0 && $('.activity_back_button').is(':visible')) {
        $('.activity_back_button').click()
        return true
    } else {
        return false
    }
}

window.calculateGroceriesChange = function() {
    $('#amount-spent, #amount-received').change(function(){
        let amountReceivedVal = $('#amount-received').val()
        let amountSpentVal = $('#amount-spent').val()

        if (amountSpentVal && amountReceivedVal) {
            let amountSpent = parseInt(amountSpentVal)
            let amountReceived = parseInt(amountReceivedVal)

            let change = amountReceived - amountSpent
            $('#groceries-change').val(change)
        }
    })
}

window.uncheckableRadioButtons = function() {
    delete window.patient_ate_full_plate
    delete window.full_or_partial_body_wash
    delete window.bath_or_shower
    delete window.hands_and_feet_wash

    $('input[name="completion_report[patient_ate_full_plate]"]').click(function () {
        if (typeof (window.patient_ate_full_plate) === 'undefined') {
            window.patient_ate_full_plate = $(this).val()
        } else {
            if (window.patient_ate_full_plate === $(this).val()) {
                $(this).prop('checked', false)
                delete (window.patient_ate_full_plate)
            } else {
                window.patient_ate_full_plate = $(this).val()
            }
        }
    })

    $('input[name="completion_report[full_or_partial_body_wash]"]').click(function () {
        if (typeof (window.full_or_partial_body_wash) === 'undefined') {
            window.full_or_partial_body_wash = $(this).val()
        } else {
            if (window.full_or_partial_body_wash === $(this).val()) {
                $(this).prop('checked', false)
                delete (window.full_or_partial_body_wash)
            } else {
                window.full_or_partial_body_wash = $(this).val()
            }
        }
    })

    $('input[name="completion_report[bath_or_shower]"]').click(function () {
        if (typeof (window.bath_or_shower) === 'undefined') {
            window.bath_or_shower = $(this).val()
        } else {
            if (window.bath_or_shower === $(this).val()) {
                $(this).prop('checked', false)
                delete (window.bath_or_shower)
            } else {
                window.bath_or_shower = $(this).val()
            }
        }
    })

    $('input[name="completion_report[hands_and_feet_wash]"]').click(function () {
        if (typeof (window.hands_and_feet_wash) === 'undefined') {
            window.hands_and_feet_wash = $(this).val()
        } else {
            if (window.hands_and_feet_wash === $(this).val()) {
                $(this).prop('checked', false)
                delete (window.hands_and_feet_wash)
            } else {
                window.hands_and_feet_wash = $(this).val()
            }
        }
    })
}

window.completionReportGeolocationRequest = function(){
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(completionReportGeolocationSuccessCallback, completionReportGeolocationFailureCallback)
    } 
}

window.completionReportGeolocationSuccessCallback = function(geolocationPosition) {
    console.log('found location')

    var latitude = geolocationPosition.coords.latitude 
    var longitude = geolocationPosition.coords.longitude
    var accuracy = geolocationPosition.coords.accuracy 
    var altitude = geolocationPosition.coords.altitude
    var altitudeAccuracy = geolocationPosition.coords.altitudeAccuracy
    $('#completion_report_latitude').val(latitude)
    $('#completion_report_longitude').val(longitude)
    $('#completion_report_accuracy').val(accuracy)
    $('#completion_report_altitude').val(altitude)
    $('#completion_report_geolocation_error_code').val('')
    $('#completion_report_geolocation_error_message').val('')
    $('#completion_report_altitude_accuracy').val(altitudeAccuracy)
    if ($('#geolocalization-status').length > 0) {
        $('#geolocalization-pending').hide()
        $('#geolocalization-failure').hide()
        $('#geolocalization-success').show()
    }

    if (window.submitReport) {
        console.log('successfully found location, should save report')
        $('#submit_completion_report_form').click()
        window.submitReport = false
    }
}

window.completionReportGeolocationFailureCallback = function(error) {
    console.log('failed to get geolocation')
    console.log(error.message)

    $('#completion_report_latitude').val('')
    $('#completion_report_longitude').val('')
    $('#completion_report_accuracy').val('')
    $('#completion_report_altitude').val('')
    $('#completion_report_geolocation_error_code').val(error.code)
    $('#completion_report_geolocation_error_message').val(error.message)

    if ($('#geolocalization-status').length > 0) {
        $('#geolocalization-pending').hide()
        $('#geolocalization-failure').show()
    }

    switch(error.code) {
        case error.PERMISSION_DENIED:
            break;
        case error.POSITION_UNAVAILABLE:
            break;
        case error.TIMEOUT:
            break;
        case error.UNKNOWN_ERROR:
            break;
    }

    if (window.submitReport) {
        console.log('should click on submit button again')
        window.requireGeolocationErrorConfirmation = true
        $('#submit-completion-report-button').click()
    }
}

window.submitCompletionReportAction = function(){
    $('#submit-completion-report-button').click(function(){
        if ($('#completion_report_latitude').val() === '') {
            if (window.requireGeolocationErrorConfirmation) {
                let message = confirm("位置情報なしで実績が確定されます。GPSエラーメッセージは保存されます。")
                if (message) {
                    $('#submit_completion_report_form').click()
                }
                window.submitReport = false
                window.requireGeolocationErrorConfirmation = false 
            } else {
                window.submitReport = true
                completionReportGeolocationRequest()
            }
    
        } else {
            $('#submit_completion_report_form').click()
            window.submitReport = false
        }
    })
}

window.colibriClickableRow = function(){
    $('.colibri-clickable-row').unbind()
    $('.colibri-clickable-row').click(function(){
        $.getScript($(this).data('url'))
    })
} 

window.careManagerCorporationActions = function() {
    $('.edit-care-manager-corporation-button').unbind()
    $('.create-care-manager-button').unbind()

    $('.edit-care-manager-corporation-button').click(function(e){
        e.stopPropagation()
        $.getScript($(this).data('url'))
    })

    $('.create-care-manager-button').click(function(e){
        e.stopPropagation()
        $.getScript($(this).data('url'))
    })
}

window.toggleCareManagers = function() {
    $('.care-manager-corporation-header').unbind()
    $('.care-manager-corporation-header').click(function(){
        if (!$(this).hasClass('already-loaded'))  {
            $.getScript(`/care_manager_corporations/${$(this).data('care-manager-corporation-id')}/care_managers.js`)
            $(this).addClass('already-loaded')
        }
        $(this).next().toggle()
        $(this).find('span.toggle-arrow-left').toggle()
    })
}

window.toggleKaigoCertificationStatus = function() {
    $('#pending_kaigo_certification').click(function(){
        $('input[name="care_plan[kaigo_level]"]').prop('checked', false)
        $('input[name="care_plan[handicap_level]"]').prop('checked', false)
        $('#kaigo-level-container').hide()
        $('#handicap-level-container').hide()
    })

    $('#completed_kaigo_certification').click(function(){
        $('#kaigo-level-container').show()
        $('#handicap-level-container').show()
    })
}

document.addEventListener('turbolinks:load', function () {

    $('#select-completed-reports').click(function(){
        $('#completed-reports').show()
        $('#uncompleted-reports').hide()
        $('.colibri-horizontal-menu-item').removeClass('item-selected')
        $(this).addClass('item-selected')
    })

    $('#select-uncompleted-reports').click(function(){
        $('#completed-reports').hide()
        $('#uncompleted-reports').show()
        $('.colibri-horizontal-menu-item').removeClass('item-selected')
        $(this).addClass('item-selected')
    })

    if ($('#care-manager-corporations-container').length > 0) {
        careManagerCorporationActions()
        toggleCareManagers()
    }

    $('.btn-scroll').click(function(){
        var aTag = $("#" + $(this).data('anchor'));
        $('html,body').animate({ scrollTop: aTag.offset().top }, 'slow')
    })

    $('.nurse-subsection-toggleable').click(function(){
        $(this).next().toggle()
        $(this).find('span').toggle()
    })

    $('.nurse-subsection-toggleable p').click(function(e){
        e.stopPropagation()
    })

    $('.header-submenu-item').click(function(){
        $('.header-submenu-item').removeClass('header-submenu-item-selected')
        $(this).addClass('header-submenu-item-selected')
    })

    $('.activity_subheader_item ').click(function(){
        $('.activity_subheader_item ').removeClass('activity_subheader_item_selected')
        $(this).addClass('activity_subheader_item_selected')
    })

    if ($('#daily-completion-reports-container').length > 0) {
        $.getScript(`/completion_reports.js?day=${moment().format('YYYY-MM-DD')}`)
    }

    $('#posts_item_selected').click(function(){
        $('#posts-widget-container').show()
        $('#daily-completion-reports-container').hide()
        $(".activity_body").scrollTop($("#posts-container")[0].scrollHeight)
    })

    $('#completion_reports_selected').click(function(){
        $('#posts-widget-container').hide()
        $('#daily-completion-reports-container').show()
    })

    $('.colibri-clickable-row').click(function(){
        $.getScript($(this).data('url'))
    })

    $('#posts-lookup-button, #dismiss-posts-lookup').click(function(){
        $('#lookup-button-container').toggle()
        $('#lookup-fields-container').toggle()
    })

    $('#email-nurses-wages').click(function(){
        $('#remote-container').html($('#email-nurses-wages-modal'))
        $('#email-nurses-wages-modal').modal('show')
    })

    $('.kana-header').click(function(){
        if (!$(this).hasClass('already-loaded'))  {
            $.getScript(`/search_by_kana_group/patients?kana_group=${$(this).data('kana-group')}`)
            $(this).addClass('already-loaded')
        }
        $(this).next().toggle()
        $(this).children('.kana-toggle-arrow').toggle()
    })


    $(document).on("mousedown", "[data-ripple]", function(e){
        var $self = $(this);

        if ($self.is(".btn-disabled")) {
            return;
        }
        if ($self.closest("[data-ripple]")) {
            e.stopPropagation();
        }

        var initPos = $self.css("position"),
            offs = $self.offset(),
            x = e.pageX - offs.left,
            y = e.pageY - offs.top,
            dia = Math.min(this.offsetHeight, this.offsetWidth, 100), // start diameter
            $ripple = $('<div/>', { class: "ripple", appendTo: $self });

        if (!initPos || initPos === "static") {
            $self.css({ position: "relative" });
        } 
        
        $('<div/>', {
            class: "rippleWave",
            css: {
                background: $self.data("ripple"),
                width: dia,
                height: dia,
                left: x - (dia / 2),
                top: y - (dia / 2),
            },
            appendTo: $ripple,
            one: {
                animationend: function () {
                    $ripple.remove();
                }
            }
        });
    })

})