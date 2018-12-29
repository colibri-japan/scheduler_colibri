class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :destroy, :archive, :toggle_cancelled, :toggle_edit_requested]
  before_action :set_planning, except: [:new_batch_delete, :new_batch_cancel, :new_batch_request_edit]
  before_action :set_corporation


  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :is_employee?

    if params[:nurse_id].present? && params[:master].present?
      @appointments = @planning.appointments.to_be_displayed.where(nurse_id: params[:nurse_id], master: params[:master])
    elsif params[:patient_id].present? && params[:master].present?
      @appointments = @planning.appointments.to_be_displayed.where(patient_id: params[:patient_id], master: params[:master])
    elsif params[:master] == 'true' && params[:nurse_id].blank? && params[:patient_id].blank?
      @appointments = @planning.appointments.to_be_displayed.from_master.includes(:patient)
    else
     @appointments = @planning.appointments.to_be_displayed.where(master: false).includes(:patient, :nurse)
    end
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @nurses = @corporation.nurses.all 
    @patients = @corporation.patients.all
  end

  # GET /appointments/1/edit
  def edit  
    @nurses = @corporation.nurses.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
    @activities = PublicActivity::Activity.where(trackable_type: 'Appointment', trackable_id: @appointment.id).all
    @recurring_appointment = RecurringAppointment.find(@appointment.recurring_appointment_id) if @appointment.recurring_appointment_id.present?
  end

  # POST /appointments
  # POST /appointments.json
  def create
    @appointment = @planning.appointments.new(appointment_params)

    respond_to do |format|
      if @appointment.save
        @activity = @appointment.create_activity :create, owner: current_user, planning_id: @planning.id
        format.html { redirect_to @appointment, notice: 'Appointment was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new }
        format.js
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    @appointment = Appointment.find(params[:id])
    store_original_params
    @appointment.recurring_appointment_id = nil

    if @appointment.update(appointment_params)
      @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_edit_requested: @previous_edit_requested, previous_title: @previous_title, new_start: @appointment.starts_at, new_end: @appointment.ends_at, new_edit_requested: @appointment.edit_requested, new_nurse: @appointment.nurse.try(:name), new_patient: @appointment.patient.try(:name), new_title: @appointment.title, new_color: @appointment.color
    end
  end

  def toggle_cancelled
    if @appointment.update_attribute(:cancelled, !@appointment.cancelled)
      @activity = @appointment.create_activity :toggle_cancelled, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_cancelled: !@appointment.cancelled
    end
  end

  def archive
    @appointment.archive 
    @appointment.recurring_appointment_id = nil 

    if @appointment.save(validate: false)
      @activity = @appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @appointment.nurse.try(:name), previous_patient: @appointment.patient.try(:name), previous_start: @appointment.starts_at, previous_end: @appointment.ends_at
    end
  end

  def toggle_edit_requested
    @appointment.edit_requested = !@appointment.edit_requested
    @appointment.recurring_appointment_id = nil

    if @appointment.save(validate: false)
      @activity = @appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_edit_requested: !@appointment.edit_requested
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @activity = @appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @appointment.nurse.try(:name), previous_patient: @appointment.patient.try(:patient), previous_end: @appointment.ends_at, previous_start: @appointment.starts_at
    @appointment.delete
  end

  def new_batch_delete
    @nurses = @corporation.nurses.displayable.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
  end

  def batch_delete_confirm
  end

  def batch_delete
  end  

  def new_batch_cancel
    @nurses = @corporation.nurses.displayable.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
  end

  def batch_cancel_confirm
  end

  def batch_cancel
  end

  def new_batch_request_edit
    @nurses = @corporation.nurses.displayable.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
  end

  def batch_request_edit_confirm
  end

  def batch_request_edit 
  end


  private
    # Use methods to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def store_original_params
      @previous_patient = @appointment.patient.try(:name)
      @previous_start = @appointment.starts_at
      @previous_end = @appointment.ends_at
      @previous_nurse = @appointment.nurse.try(:name)
      @previous_edit_requested = @appointment.edit_requested
      @previous_title = @appointment.title
    end

    def set_corporation
      @corporation = Corporation.find(current_user.corporation_id)
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    def from_master_planning?
      params[:q] == 'master' ? @master = true : @master = false
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:title, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id, :color, :edit_requested)
    end
end
