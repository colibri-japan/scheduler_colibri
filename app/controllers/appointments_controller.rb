class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :archive, :toggle_cancelled, :toggle_edit_requested]
  before_action :set_planning, except: [:new_batch_archive, :new_batch_cancel, :new_batch_request_edit, :batch_archive_confirm, :batch_cancel_confirm, :batch_request_edit_confirm, :batch_archive, :batch_cancel, :batch_request_edit]
  before_action :set_corporation
  before_action :new_batch_action, only: [:new_batch_archive, :new_batch_cancel, :new_batch_request_edit]
  before_action :confirm_batch_action, only: [:batch_cancel_confirm, :batch_archive_confirm, :batch_request_edit_confirm]

  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :same_corporation_as_current_user?

    if params[:nurse_id].present? && params[:master].present?
      @appointments = @planning.appointments.to_be_displayed.where(nurse_id: params[:nurse_id], master: params[:master]).includes(:patient, :nurse, :recurring_appointment)
    elsif params[:patient_id].present? && params[:master].present?
      @appointments = @planning.appointments.to_be_displayed.where(patient_id: params[:patient_id], master: params[:master]).includes(:patient, :nurse, :recurring_appointment)
    elsif params[:master] == 'true' && params[:nurse_id].blank? && params[:patient_id].blank?
      @appointments = @planning.appointments.to_be_displayed.from_master.includes(:patient, :nurse, :recurring_appointment)
    else
     @appointments = @planning.appointments.to_be_displayed.where(master: false).includes(:patient, :nurse, :recurring_appointment)
    end

    if params[:start].present? && params[:end].present? 
      @appointments = @appointments.overlapping(params[:start]..params[:end])
    end

    patient_resource = params[:patient_resource].present?

    respond_to do |format|
      format.json {render json: @appointments.as_json(patient_resource: patient_resource)}
    end

  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    authorize @planning, :same_corporation_as_current_user?

    @appointment = Appointment.new
    @nurses = @corporation.nurses.all 
    @patients = @corporation.patients.all
  end

  # GET /appointments/1/edit
  def edit  
    authorize @planning, :same_corporation_as_current_user?

    @nurses = @corporation.nurses.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
    @activities = PublicActivity::Activity.where(trackable_type: 'Appointment', trackable_id: @appointment.id, planning_id: @planning.id).all
    @services = @corporation.cached_most_used_services_for_select
    @recurring_appointment = RecurringAppointment.find(@appointment.recurring_appointment_id) if @appointment.recurring_appointment_id.present?
  end

  # POST /appointments
  # POST /appointments.json
  def create
    authorize @planning, :same_corporation_as_current_user?

    @appointment = @planning.appointments.new(appointment_params) 

    if @appointment.save 
      @activity = @appointment.create_activity :create, owner: current_user, planning_id: @planning.id
    else 
    end
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    authorize @planning, :same_corporation_as_current_user?

    @appointment = Appointment.find(params[:id])
    store_original_params
    @appointment.recurring_appointment_id = nil
    
    if @appointment.update(appointment_params)      
      @provided_service = @appointment.provided_service if @previous_cancelled != appointment_params[:cancelled]
      @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_edit_requested: @previous_edit_requested, previous_title: @previous_title, new_start: @appointment.starts_at, new_end: @appointment.ends_at, new_edit_requested: @appointment.edit_requested, new_nurse: @appointment.nurse.try(:name), new_patient: @appointment.patient.try(:name), new_title: @appointment.title, new_color: @appointment.color
      recalculate_bonus
    end
  end

  def toggle_cancelled
    authorize @planning, :same_corporation_as_current_user?

    @appointment.cancelled = !@appointment.cancelled
    @appointment.recurring_appointment_id = nil 

    if @appointment.save(validate: !@appointment.cancelled)
      @provided_service = @appointment.provided_service
      @activity = @appointment.create_activity :toggle_cancelled, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_cancelled: !@appointment.cancelled
      recalculate_bonus
    end
  end

  def archive
    authorize @planning, :same_corporation_as_current_user?

    @appointment.archive 
    @appointment.recurring_appointment_id = nil 

    if @appointment.save(validate: false)
      @activity = @appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @appointment.nurse.try(:name), previous_patient: @appointment.patient.try(:name), previous_start: @appointment.starts_at, previous_end: @appointment.ends_at
      recalculate_bonus
    end
  end

  def toggle_edit_requested
    authorize @planning, :same_corporation_as_current_user?

    @appointment.edit_requested = !@appointment.edit_requested
    @appointment.recurring_appointment_id = nil

    if @appointment.save(validate: false)
      @activity = @appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_edit_requested: !@appointment.edit_requested
      recalculate_bonus
    end
  end


  def new_batch_archive
  end

  def batch_archive_confirm
  end

  def batch_archive
    planning_id = @corporation.planning.id
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: planning_id)
    @provided_services = ProvidedService.where(planning_id: planning_id, appointment_id: @appointments.ids)
    
    now = Time.current
    @appointments.update_all(archived_at: now, recurring_appointment_id: nil, updated_at: now)
    @provided_services.update_all(archived_at: now, total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: now)

    batch_recalculate_bonus
  end  

  def new_batch_cancel
  end

  def batch_cancel_confirm
  end

  def batch_cancel
    planning_id = @corporation.planning.id
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: planning_id)
    @provided_services = ProvidedService.where(planning_id: planning_id, appointment_id: @appointments.ids)

    now = Time.current
    @appointments.update_all(cancelled: true, recurring_appointment_id: nil, updated_at: now)
    @provided_services.update_all(cancelled: true, total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: now)

    batch_recalculate_bonus
  end

  def new_batch_request_edit
  end

  def batch_request_edit_confirm
  end

  def batch_request_edit 
    planning_id = @corporation.planning.id 
    @appointments = Appointment.where(id: params[:appointment_ids], planning_id: planning_id)
    @provided_services = ProvidedService.where(planning_id: planning_id, appointment_id: @appointments.ids)

    now = Time.current
    @appointments.update_all(edit_requested: true, recurring_appointment_id: nil, updated_at: now)
    @provided_services.update_all(total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: now)

    batch_recalculate_bonus
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

      @appointments = Appointment.to_be_displayed.where(planning_id: planning_id, master: false).overlapping(params[:range_start]..params[:range_end]).order(:starts_at)

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

    def store_original_params
      @previous_patient = @appointment.patient.try(:name)
      @previous_start = @appointment.starts_at
      @previous_end = @appointment.ends_at
      @previous_nurse = @appointment.nurse.try(:name)
      @previous_nurse_id = @appointment.nurse_id
      @previous_edit_requested = @appointment.edit_requested
      @previous_cancelled = @appointment.edit_requested
      @previous_title = @appointment.title
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    def recalculate_bonus
      RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@appointment.nurse_id, @appointment.starts_at.year, @appointment.starts_at.month)
      RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@previous_nurse_id, @appointment.starts_at.year, @appointment.starts_at.month) if @previous_nurse_id.present? && @previous_nurse_id != @appointment.nurse_id
    end

    def batch_recalculate_bonus
      nurse_ids = @provided_services.pluck(:nurse_id).uniq
      year_and_months = @provided_services.pluck(:service_date).map{|d| {year: d.year, month: d.month}}.uniq

      nurse_ids.each do |nurse_id|
        year_and_months.each do |year_and_month|
          RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(nurse_id, year_and_month[:year], year_and_month[:month])
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:title, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id, :color, :edit_requested, :cancelled)
    end
end
