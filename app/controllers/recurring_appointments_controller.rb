class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :archive, :from_master_to_general, :terminate, :create_individual_appointments]
  before_action :set_planning
  before_action :set_corporation
  before_action :set_grouped_nurses, only: [:new, :edit]
  before_action :set_patients, only: [:new, :edit]


  def index
    @recurring_appointments = @planning.recurring_appointments.where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', params[:start].to_date.beginning_of_day).not_archived.includes(:patient, :nurse)

    @recurring_appointments = @recurring_appointments.where(nurse_id: params[:nurse_id]) if params[:nurse_id].present? && params[:nurse_id] != 'undefined'
    @recurring_appointments = @recurring_appointments.where(patient_id: params[:patient_id]) if params[:patient_id].present? && params[:patient_id] != 'undefined'

    if stale?(@recurring_appointments)
      respond_to do |format|
        format.json {render json: @recurring_appointments.as_json(start_time: params[:start], end_time: params[:end]).flatten}
        format.js
      end
    end
  end

  def show
  end

  def new
    authorize current_user, :has_admin_access?
    
    @recurring_appointment = RecurringAppointment.new
    @services = @corporation.cached_most_used_services_for_select
  end
  
  def edit
    authorize current_user, :has_admin_access?
    
    recurring_appointment_ids = @recurring_appointment.original_id.present? ? [@recurring_appointment.id, @recurring_appointment.original_id] : @recurring_appointment.id
    @activities = PublicActivity::Activity.where(trackable_type: 'RecurringAppointment', trackable_id: recurring_appointment_ids).includes(:owner)
    @services = @corporation.cached_most_used_services_for_select
  end
  
  def create
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
    
    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, parameters: {anchor: @recurring_appointment.anchor, starts_at: @recurring_appointment.starts_at, ends_at: @recurring_appointment.ends_at, title: @recurring_appointment.title, nurse_name: @recurring_appointment.nurse.try(:name), patient_name: @recurring_appointment.patient.try(:name)}
    end
  end
  
  def update    
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @recurring_appointment = RecurringAppointment.find(params[:id])
    @recurring_appointment.attributes = recurring_appointment_params
    
    redefine_anchor_if_editing_after_some_date
    @parameters_for_activity = @recurring_appointment.changes
    
    if @recurring_appointment.save
      @new_recurring_appointment = RecurringAppointment.where(original_id: @recurring_appointment.id).last
      create_activities_for_update
    end
  end
  
  def terminate 
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @termination_date = params[:t_date].to_date.beginning_of_day
    @recurring_appointment.termination_date = @termination_date
    if @recurring_appointment.save 
      cancel_appointments_after_termination
      @activity = @recurring_appointment.create_activity :terminate, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, parameters: {nurse_name: @recurring_appointment.nurse.try(:name), patient_name: @recurring_appointment.patient.try(:name), anchor: @recurring_appointment.anchor, starts_at: @recurring_appointment.starts_at, ends_at: @recurring_appointment.ends_at, title: @recurring_appointment.title, termination_date: @recurring_appointment.termination_date}
    end
  end
  
  def archive
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @recurring_appointment.archive 
    
    if @recurring_appointment.save(validate: false)
      cancel_all_appointments
      @activity = @recurring_appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, parameters: {nurse_name: @recurring_appointment.nurse.try(:name), patient_name: @recurring_appointment.patient.try(:name), anchor: @recurring_appointment.anchor, starts_at: @recurring_appointment.starts_at, ends_at: @recurring_appointment.ends_at, title: @recurring_appointment.title}
    end                  
  end
  
  def create_individual_appointments
    CreateIndividualAppointmentsWorker.perform_async(@recurring_appointment.id, params[:option1][:year], params[:option1][:month], params[:option2][:year], params[:option2][:month], params[:option3][:year], params[:option3][:month], params[:option2IsSelected], params[:option3IsSelected])
  end

  private

    def redefine_anchor_if_editing_after_some_date
      if recurring_appointment_params[:anchor].blank? && recurring_appointment_params[:editing_occurrences_after].present?
        @recurring_appointment.anchor = recurring_appointment_params[:editing_occurrences_after].to_date
      end
    end

    def set_recurring_appointment
      @recurring_appointment = RecurringAppointment.find(params[:id])
    end

    def set_grouped_nurses
      @grouped_nurses_for_select = @corporation.cached_displayable_nurses_grouped_by_fulltimer_for_select
    end

    def set_patients
      @patients = @corporation.cached_active_patients_ordered_by_kana
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    def cancel_appointments_after_termination
      appointment_ids = Appointment.where(recurring_appointment_id: @recurring_appointment.id).not_archived.where('starts_at > ?', params[:t_date].to_date.beginning_of_day).ids 
      CancelAppointmentsWorker.perform_async(appointment_ids) if appointment_ids.present?
    end

    def cancel_all_appointments
      appointment_ids = Appointment.not_archived.where(recurring_appointment_id: @recurring_appointment.id).ids 
      CancelAppointmentsWorker.perform_async(appointment_ids) if appointment_ids.present?
    end

    def recalculate_bonus
      if @new_recurring_appointment.present?
        year_and_months = [{year: @new_recurring_appointment.anchor.year, month: @new_recurring_appointment.anchor.month}]
      elsif @termination_date.present?
        year_and_months = [{year: @termination_date.year, month: @termination_date.month}]
      else
        year_and_months = Appointment.where(recurring_appointment_id: @recurring_appointment.id).not_archived.pluck(:starts_at).map{|d| {year: d.year, month: d.month}}.uniq
      end

      year_and_months.each do |year_and_month|
        RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@recurring_appointment.nurse_id, year_and_month[:year], year_and_month[:month])
        RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(@new_recurring_appointment.nurse_id, year_and_month[:year], year_and_month[:month]) if @new_recurring_appointment.present? && @new_recurring_appointment.nurse_id != @recurring_appointment.nurse_id
      end
    end

    def create_activities_for_update
      @parameters_for_activity["previous_patient_name"] = @recurring_appointment.patient.try(:name)
      @parameters_for_activity["previous_nurse_name"] = @recurring_appointment.nurse.try(:name)
      @parameters_for_activity["nurse_name"] = @new_recurring_appointment.nurse.try(:name) if @parameters_for_activity['nurse_id'].present?
      @parameters_for_activity["patient_name"] = @new_recurring_appointment.patient.try(:name) if @parameters_for_activity['patient_id'].present?
      @parameters_for_activity["starts_at"] = [@recurring_appointment.starts_at, nil] unless @parameters_for_activity['starts_at'].present?
      @parameters_for_activity["ends_at"] = [@recurring_appointment.ends_at, nil] unless @parameters_for_activity['ends_at'].present?
      @parameters_for_activity["anchor"] = [@recurring_appointment.anchor, nil] unless @parameters_for_activity['anchor'].present?

      @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, previous_nurse_id: @recurring_appointment.nurse_id, nurse_id: @new_recurring_appointment.nurse_id, previous_patient_id: @recurring_appointment.patient_id, patient_id: @new_recurring_appointment.patient_id, parameters: @parameters_for_activity
    end

    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :starts_at, :ends_at, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :duration, :editing_occurrences_after, :service_id, :synchronize_appointments)
    end


end
