class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :archive, :toggle_verified, :new_cancellation_fee, :toggle_second_verified, :toggle_cancelled, :toggle_edit_requested]
  before_action :set_corporation
  before_action :set_planning

  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :same_corporation_as_current_user?

    if params[:nurse_id].present? 
      @appointments = Appointment.where(nurse_id: params[:nurse_id]).not_archived.includes(:patient, :nurse, :completion_report)
    elsif params[:patient_id].present?
      @appointments = Appointment.where(patient_id: params[:patient_id]).not_archived.includes(:patient, :nurse, :completion_report)
    elsif params[:team_id].present? 
      @appointments = Appointment.where(nurse_id: Team.find(params[:team_id]).nurses.pluck(:id)).not_archived.includes(:patient, :nurse, :completion_report)
    else
      @appointments = @planning.appointments.not_archived.includes(:patient, :nurse, :completion_report)
    end

    if params[:start].present? && params[:end].present? 
      @appointments = @appointments.in_range(params[:start]..params[:end])
    end

    if stale?(@appointments)
      respond_to do |format|
        format.json {render json: @appointments.as_json(list_view: params[:list_view].present?)}
      end
    end
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
    @patient = @appointment.patient
    @recent_reports = CompletionReport.with_general_comment.where(reportable_type: 'Appointment', reportable_id: Appointment.operational.where(patient_id: @appointment.patient_id).where('starts_at < ?', Time.current.in_time_zone('Tokyo')).order(starts_at: :desc).limit(15).ids).includes(reportable: :nurse).joins('LEFT JOIN appointments on appointments.id = completion_reports.reportable_id').order('appointments.starts_at DESC')
  end

  # GET /appointments/1/edit
  def edit  
    authorize @planning, :same_corporation_as_current_user?

    fetch_patients

    @completion_report = @appointment.completion_report
    @grouped_nurses_for_select = @corporation.cached_nurses_grouped_by_fulltimer_for_select
    @activities = PublicActivity::Activity.where(trackable_type: 'Appointment', trackable_id: @appointment.id, planning_id: @planning.id).includes(:owner)
    @services_with_recommendations = @corporation.cached_most_used_services_for_select

    respond_to do |format|
      format.js 
      format.js.phone
    end
  end

  # POST /appointments
  # POST /appointments.json
  def create
    authorize @planning, :same_corporation_as_current_user?

    @appointment = @planning.appointments.new(appointment_params) 

    if @appointment.save 
      @activity = @appointment.create_activity :create, owner: current_user, planning_id: @planning.id, parameters: {patient_name: @appointment.patient.try(:name), nurse_name: @appointment.nurse.try(:name), starts_at: @appointment.starts_at, ends_at: @appointment.ends_at}
    end
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    authorize @planning, :same_corporation_as_current_user?

    @appointment = Appointment.find(params[:id])
    @appointment.recurring_appointment_id = nil
    
    if @appointment.update(appointment_params)      
      create_activity_for_update
      recalculate_bonus
    end
  end

	def toggle_verified
		@appointment.toggle_verified!(current_user.id)
	end

	def toggle_second_verified
		@appointment.toggle_second_verified!(current_user.id)
	end

  def toggle_cancelled
    authorize @planning, :same_corporation_as_current_user?

    @appointment.cancelled = !@appointment.cancelled
    @appointment.recurring_appointment_id = nil 

    if @appointment.save(validate: !@appointment.cancelled)
      @activity = @appointment.create_activity :toggle_cancelled, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, parameters: {starts_at: @appointment.starts_at, ends_at: @appointment.ends_at, previous_cancelled: !@appointment.cancelled, patient_name: @appointment.patient.try(:name), nurse_name: @appointment.nurse.try(:name)}
      recalculate_bonus
    end
  end

  def archive
    authorize @planning, :same_corporation_as_current_user?

    @appointment.archive 
    @appointment.recurring_appointment_id = nil 
    
    respond_to do |format|
      if @appointment.save(validate: false)
        @activity = @appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, previous_nurse_id: @appointment.nurse_id, previous_patient_id: @appointment.patient_id, parameters: {starts_at: @appointment.starts_at, ends_at: @appointment.ends_at, previous_nurse_name: @appointment.nurse.try(:name), previous_patient_name: @appointment.patient.try(:name)}
        recalculate_bonus

        format.js 
        format.js.phone
      end
    end
  end

  def toggle_edit_requested
    authorize @planning, :same_corporation_as_current_user?

    @appointment.edit_requested = !@appointment.edit_requested
    @appointment.recurring_appointment_id = nil

    if @appointment.save(validate: !@appointment.edit_requested)
      @activity = @appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, parameters: {starts_at: @appointment.starts_at, ends_at: @appointment.ends_at, previous_edit_requested: !@appointment.edit_requested, patient_name: @appointment.patient.try(:name), nurse_name: @appointment.nurse.try(:name)} 
      recalculate_bonus
    end
  end

	def new_cancellation_fee
	end

  def new_batch_action
      fetch_team_nurses
      fetch_patients
  end

  def batch_action_confirm
      @planning = @corporation.planning

      range_array = params[:date_range].split('-')
      range = Range.new(range_array[0].to_datetime, range_array[1].to_datetime) rescue Date.today.beginning_of_day..Date.today.end_of_day 

      @appointments = @planning.appointments.not_archived.includes(:patient, :nurse).in_range(range).order(:starts_at)

      @appointments = @appointments.where(nurse_id: params[:nurse_ids]) if params[:nurse_ids].present?
      @appointments = @appointments.where(patient_id: params[:patient_ids]) if params[:patient_ids].present?

      filter_appointments_by_action_type

      @action_type = params[:action_type]
  end

  def batch_archive
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: @planning.id)
    
    now = Time.current
    @appointments.update_all(archived_at: now, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_archive, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}

    batch_recalculate_salaries(bonus_only: true)
  end  


  def batch_cancel
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: @planning.id)

    now = Time.current
    @appointments.update_all(cancelled: true, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_cancel, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}
    batch_recalculate_salaries(bonus_only: true)
  end


  def batch_request_edit 
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: @planning.id)

    now = Time.current
    @appointments.update_all(edit_requested: true, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_request_edit, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}

    batch_recalculate_salaries(bonus_only: true)
  end

  def batch_restore_to_operational
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: @planning.id)
    @overlapping_appointments = []

    validate_appointments_before_restoring_to_operational

    unless @overlapping_appointments.present?
      now = Time.current
      @appointments.update_all(edit_requested: false, cancelled: false, updated_at: now)
      @planning.create_activity :batch_restore_to_operational, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}
    
      batch_recalculate_salaries(bonus_only: false)
    end
  end

	def appointments_by_category_report
		set_planning

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

		@appointments_grouped_by_category = @planning.appointments.edit_not_requested.not_archived.includes(:service).in_range(first_day..last_day).grouped_by_weighted_category(categories: params[:categories].try(:split,','))
		@available_categories = @corporation.services.where(nurse_id: nil).pluck(:category_1, :category_2).flatten.uniq
  end
  
  def monthly_revenue_report
    set_planning 
    
    @revenue_grouped_by_month = @planning.appointments.edit_not_requested.not_archived.includes(:service).joins(:service).in_range((Date.today - 5.months).beginning_of_month..Date.today.end_of_day).revenue_grouped_by_month
  end


  private
    # Use methods to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def create_activity_for_update
      parameters = @appointment.previous_changes
      parameters["previous_nurse_name"] = Nurse.find(parameters["nurse_id"][0]).try(:name) if parameters["nurse_id"].present?
      parameters["previous_patient_name"] = Patient.find(parameters["patient_id"][0]).try(:name) if parameters["patient_id"].present? 
      parameters["nurse_name"] = @appointment.nurse.try(:name)
      parameters["patient_name"] = @appointment.patient.try(:name)
      parameters["starts_at"] = [@appointment.starts_at, nil]  unless parameters["starts_at"].present?
      parameters["ends_at"] = [@appointment.ends_at, nil]  unless parameters["ends_at"].present?
      previous_nurse_id = parameters["nurse_id"].present? ? parameters["nurse_id"][0] : nil
      previous_patient_id = parameters["patient_id"].present? ? parameters["patient_id"][0] : nil
      parameters.delete("updated_at")

      @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse_id: previous_nurse_id, previous_patient_id: previous_patient_id, parameters: parameters
    end

    def filter_appointments_by_action_type
      cancelled = params[:cancelled].present? ? params[:cancelled] : false
      edit_requested = params[:edit_requested].present? ? params[:edit_requested] : false
      operational = params[:operational].present? ? params[:operational] : false

      if params[:action_type] == "restore_to_operational"
        if !cancelled && !edit_requested
          @appointments = @appointments.operational
        elsif !cancelled && edit_requested
          @appointments = @appointments.not_cancelled.edit_requested 
        elsif cancelled && !edit_requested
          @appointments = @appointments.cancelled
        elsif cancelled && edit_requested
          @appointments = @appointments.where('cancelled is true OR edit_requested is true')
        end
      elsif  params[:action_type] == "archive"
        if operational
          if !edit_requested && !cancelled
            @appointments = @appointments.operational
          elsif !edit_requested && cancelled
            @appointments = @appointments.edit_not_requested
          elsif edit_requested && !cancelled
            @appointments = @appointments.not_cancelled
          end
        else
          if !edit_requested && !cancelled
            @appointments = @appointments.operational
          elsif !edit_requested && cancelled
            @appointments = @appointments.cancelled
          elsif edit_requested && !cancelled
            @appointments = @appointments.edit_requested
          elsif cancelled && edit_requested
            @appointments = @appointments.where('cancelled is true OR edit_requested is true')
          end
        end
      end
    end

    def validate_appointments_before_restoring_to_operational
      #validate from existing appointments
      @appointments.each do |a|
        a.attributes = {edit_requested: false, cancelled: false}
        
        @overlapping_appointments << a unless a.valid?
      end

      #validate within current selection
      
      @overlapping_appointments << @appointments.get_overlapping_instances

      @overlapping_appointments = @overlapping_appointments.flatten
      @overlapping_appointments = @overlapping_appointments.sort_by {|a| a.try(:starts_at) }
    end

    def recalculate_bonus 
      RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@appointment.nurse_id, @appointment.starts_at.year, @appointment.starts_at.month)
      RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@activity.parameters[:previous_nurse_id], @appointment.starts_at.year, @appointment.starts_at.month) if @activity.parameters[:previous_nurse_id].present?
    end

    def batch_recalculate_salaries(bonus_only:)
      nurse_ids = @appointments.pluck(:nurse_id).uniq
      year_and_months = @appointments.pluck(:starts_at).map{|date_time| {year: date_time.year, month: date_time.month}}.uniq

      nurse_ids.each do |nurse_id|
        year_and_months.each do |year_and_month|
          if bonus_only
            RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id,  year_and_month[:year], year_and_month[:month])
          else
            RecalculateNurseMonthlyWageWorker.perform_async(nurse_id, year_and_month[:year], year_and_month[:month])
          end
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:service_id, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id, :color, :edit_requested, :cancelled, :skip_credits_invoice_and_wage_calculations, :total_wage, :total_invoiced)
    end
end
