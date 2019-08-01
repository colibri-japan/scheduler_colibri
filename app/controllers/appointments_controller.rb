class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :archive, :toggle_verified, :new_cancellation_fee, :toggle_second_verified, :toggle_cancelled, :toggle_edit_requested]
  before_action :set_corporation
  before_action :set_planning, except: [:new_batch_archive, :new_batch_cancel, :new_cancellation_fee, :new_batch_request_edit, :batch_archive_confirm, :batch_cancel_confirm, :batch_request_edit_confirm]
  before_action :new_batch_action, only: [:new_batch_archive, :new_batch_cancel, :new_batch_request_edit]
  before_action :confirm_batch_action, only: [:batch_cancel_confirm, :batch_archive_confirm, :batch_request_edit_confirm]

  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :same_corporation_as_current_user?

    if params[:nurse_id].present? 
      @appointments = @planning.appointments.not_archived.where(nurse_id: params[:nurse_id]).includes(:patient, :nurse, :recurring_appointment)
    elsif params[:patient_id].present?
      @appointments = @planning.appointments.not_archived.where(patient_id: params[:patient_id]).includes(:patient, :nurse, :recurring_appointment)
    else
     @appointments = @planning.appointments.not_archived.includes(:patient, :nurse, :recurring_appointment)
    end

    if params[:start].present? && params[:end].present? 
      @appointments = @appointments.overlapping(params[:start]..params[:end])
    end

    patient_resource = params[:patient_resource].present?

    if stale?(@appointments)
      respond_to do |format|
        format.json {render json: @appointments.as_json(patient_resource: patient_resource)}
      end
    end

  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
  end

  # GET /appointments/1/edit
  def edit  
    authorize @planning, :same_corporation_as_current_user?

    @nurses = @corporation.nurses.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
    @activities = PublicActivity::Activity.where(trackable_type: 'Appointment', trackable_id: @appointment.id, planning_id: @planning.id).includes(:owner)
    @services_with_recommendations = @corporation.cached_most_used_services_for_select
    @recurring_appointment = RecurringAppointment.find(@appointment.recurring_appointment_id) if @appointment.recurring_appointment_id.present?
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
    
    if @appointment.save(validate: false)
      @activity = @appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, previous_nurse_id: @appointment.nurse_id, previous_patient_id: @appointment.patient_id, parameters: {starts_at: @appointment.starts_at, ends_at: @appointment.ends_at, previous_nurse_name: @appointment.nurse.try(:name), previous_patient_name: @appointment.patient.try(:name)}
      recalculate_bonus
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

  def new_batch_archive
  end

  def batch_archive_confirm
  end

  def batch_archive
    planning_id = @corporation.planning.id
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: planning_id)
    
    now = Time.current
    @appointments.update_all(archived_at: now, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_archive, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}

    batch_recalculate_bonus
  end  

  def new_batch_cancel
  end

  def batch_cancel_confirm
  end

  def batch_cancel
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: @planning.id)

    now = Time.current
    @appointments.update_all(cancelled: true, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_cancel, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}
    batch_recalculate_bonus
  end

  def new_batch_request_edit
  end

  def batch_request_edit_confirm
  end

  def batch_request_edit 
    planning_id = @corporation.planning.id 
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: planning_id)

    now = Time.current
    @appointments.update_all(edit_requested: true, total_wage: 0, total_credits: 0, total_invoiced: 0, recurring_appointment_id: nil, updated_at: now)

    @planning.create_activity :batch_request_edit, owner: current_user, planning_id: @planning.id, parameters: {appointment_ids: @appointments.ids}

    batch_recalculate_bonus
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
    puts @revenue_grouped_by_month
  end


  private
    # Use methods to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def new_batch_action
      @nurses = @corporation.nurses.displayable.order_by_kana
      @patients = @corporation.patients.active.order_by_kana
    end

    def confirm_batch_action
      planning_id = @corporation.planning.id

      @appointments = Appointment.not_archived.where(planning_id: planning_id).overlapping(params[:range_start]..params[:range_end]).order(:starts_at)

      @appointments = @appointments.where(nurse_id: params[:nurse_ids]) if params[:nurse_ids].present?
      @appointments = @appointments.where(patient_id: params[:patient_ids]) if params[:patient_ids].present?
      cancelled = params[:cancelled]
      edit_requested = params[:edit_requested]

      if edit_requested == 'false' && cancelled == 'false'
        @appointments = @appointments.where('cancelled is false AND edit_requested is false')
      elsif edit_requested == 'undefined' && cancelled == 'undefined' 
      elsif edit_requested == 'undefined' && cancelled == 'false'
        @appointments = @appointments.where(cancelled: false)
      elsif edit_requested == 'false' && cancelled == 'undefined'
        @appointments = @appointments.where('(edit_requested is false) OR (edit_requested is true AND cancelled is true)')
      elsif edit_requested == 'true' && cancelled == 'false'
        @appointments = @appointments.where(edit_requested: true, cancelled: false)
      elsif edit_requested == 'undefined' && cancelled == 'true'
        @appointments = @appointments.where(cancelled: true)
      elsif edit_requested == 'true' && cancelled == 'true'
        @appointments = @appointments.where('cancelled is true OR edit_requested is true')
      end
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

    def recalculate_bonus 
      RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@appointment.nurse_id, @appointment.starts_at.year, @appointment.starts_at.month)
      RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@activity.parameters[:previous_nurse_id], @appointment.starts_at.year, @appointment.starts_at.month) if @activity.parameters[:previous_nurse_id].present?
    end

    def batch_recalculate_bonus
      nurse_ids = @appointments.pluck(:nurse_id).uniq
      year_and_months = @appointments.pluck(:starts_at).map{|date_time| {year: date_time.year, month: date_time.month}}.uniq

      nurse_ids.each do |nurse_id|
        year_and_months.each do |year_and_month|
          RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id, year_and_month[:year], year_and_month[:month])
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:service_id, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id, :color, :edit_requested, :cancelled, :skip_credits_invoice_and_wage_calculations, :total_wage, :total_invoiced)
    end
end
