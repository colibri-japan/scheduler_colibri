let postSelectize = () => {
    $('#post_patient_id').selectize({
        plugins: ['remove_button']
    });
}
window.postSelectize = postSelectize

window.selectizeCustomEmailDays = () => {
    $('#custom-email-days').selectize({
        plugins: ['remove_button'],
    })
}

window.privateEventSelectizeNursePatient = () => {
    $('#private_event_nurse_id').selectize()
    $('#private_event_patient_id').selectize()
}

window.recurringAppointmenSelectizeTitle = () => {
    $('#recurring_appointment_service_id').selectize()
};

window.recurringAppointmentSelectizeNursePatient = () => {
    $('#recurring_appointment_nurse_id').selectize();
    $('#recurring_appointment_patient_id').selectize();
}

window.appointmentSelectizeNursePatient = () => {
    $('#appointment_nurse_id').selectize();
    $('#appointment_patient_id').selectize();
}

window.appointmentSelectize = () => {
    $('#appointment_service_id').selectize()
}

window.skillsSelectize = () => {
    $('#nurse_skill_list').selectize({
        delimiter: ',',
        persist: false,
        create: true,
        plugins: ['remove_button'],
        render: {
            option_create: function (data, escape) {
                return '<div class="create">新規スキル <strong>' + escape(data.input) + '</strong>&hellip;</div>'
            }
        }
    })
}

window.wishedSlotsSelectize = () => {
    $('#wished_slot_nurse_id').selectize()
}

window.caveatsSelectize = () => {
    $('#patient_caveat_list').selectize({
        delimiter: ',',
        persist: false,
        create: true,
        plugins: ['remove_button'],
        render: {
            option_create: function (data, escape) {
                return '<div class="create">新規特徴 <strong>' + escape(data.input) + '</strong>&hellip;</div>'
            }
        }
    });
}

window.batchActionSelectize = () => {
    $('#select_action_type').selectize()
    $('#nurse_ids').selectize({
        delimiter: ',',
        plugins: ['remove_button']
    })
    $('#patient_ids').selectize({
        delimiter: ',',
        plugins: ['remove_button']
    })
}

window.nursePatientSelectize = () => {
    $('#patient_nurse_id').selectize()
}

window.selectizeAppointmentsByCategories = () => {
    $('#service_type_filter').selectize({
        plugins: ['remove_button']
    })
}

window.teamMembersSelectize = () => {
    $('#team_member_ids').selectize({
        plugins: ['remove_button'],
        persist: false,
    })
}

window.selectizeServiceToMerge = () => {
    $('#service_to_merge').selectize()
}
window.salaryRulesSelectize = () => {
    $('#target-nurse-ids').selectize({
        plugins: ['remove_button']
    })
    $('#target-service-titles').selectize({
        plugins: ['remove_button']
    })
}

window.wishesSelectize = () => {
    $('#nurse_wish_list').selectize({
        delimiter: ',',
        persist: false,
        create: true,
        plugins: ['remove_button'],
        render: {
            option_create: function (data, escape) {
                return '<div class="create">新規希望 <strong>' + escape(data.input) + '</strong>&hellip;</div>'
            }
        }
    })
}

window.wishedAreasSelectize = () => {
    $('#nurse_wished_area_list').selectize({
        delimiter: ',',
        persist: false,
        create: true,
        plugins: ['remove_button'],
        render: {
            option_create: function (data, escape) {
                return '<div class="create">新規希望エリア <strong>' + escape(data.input) + '</strong>&hellip;</div>'
            }
        }
    })
}

window.selectizeForSmartSearch = () => {
    $('#nurse_skills_tags').selectize({
        delimiter: ',',
        persist: false,
        plugins: ['remove_button']
    })
    $('#nurse_wishes_tags').selectize({
        delimiter: ',',
        persist: false,
        plugins: ['remove_button']
    })
    $('#nurse_wished_areas_tags').selectize({
        delimiter: ',',
        persist: false,
        plugins: ['remove_button']
    })
}


window.selectizeInsurancePolicy = () => {
    $('#patient-insurance-policy').selectize({
        plugins: ['remove_button']
    })
}

window.completionFormSelectize = () => {
    $('#completion_details_washing_details').selectize({
        plugins: ['remove_button'],
    })
    $('#completion_report_activities_done_with_the_patient').selectize({
        plugins: ['remove_button'],
    })
    $('#completion_report_cleanup').selectize({
        plugins: ['remove_button'],
    })
}

window.patientCaremanagerSelectize = () => {
    $('#patient_care_manager').selectize()
    $('#patient_second_care_manager').selectize()
}

let toggleNurseIdForm = () => {
    if ($('#all_nurses_selected_checkbox').is(':checked')) {
        $('#form_nurse_id_list_group').hide()
        $('#target_nurse_by_filter_group').hide()
        $('#target-nurse-ids').val('')
        if (typeof (selectize) !== 'undefined') {
            selectize.clear(true)
        }
    } else {
        $('#target_nurse_by_filter_group').show()
        $('#form_nurse_id_list_group').show()
    }
}
window.toggleNurseIdForm = toggleNurseIdForm

window.toggleNurseIdList = () => {
    $('#all_nurses_selected_checkbox').on('change', function () {
        $selectize = $('#target-nurse-ids').selectize()
        selectize = $selectize[0].selectize
        toggleNurseIdForm()
    })
}

document.addEventListener('turbolinks:load', function () {
    $('#posts_author_ids_filter').selectize({
        plugins: ['remove_button']
    })

    $('#posts_patient_ids_filter').selectize({
        plugins: ['remove_button']
    })

    $('#nurse_resource_filter').selectize({
        plugins: ['remove_button']
    })

    $('#cm_teikyohyo_filter').selectize({
        plugins: ['remove_button'],
        placeholder: '検索する...'
    })

    $('#cm_filter').selectize({
        plugins: ['remove_button'],
        placeholder: '検索する...'
    })

    $('#summary_team_select').selectize()
})