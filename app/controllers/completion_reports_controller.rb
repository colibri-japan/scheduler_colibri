class CompletionReportsController < ApplicationController

  before_action :set_corporation
  before_action :set_reportable, except: :index
  before_action :set_planning
  before_action :set_completion_report, only: [:update, :edit, :destroy]

  def new
    if @reportable.class.name == 'Appointment'
      master_report = @reportable.recurring_appointment.try(:completion_report) || @reportable.original_recurring_appointment.try(:completion_report)
      @completion_report = master_report.present? ? master_report.dup : CompletionReport.new
      @completion_report.forecasted_report = master_report
      @completion_report.reportable = @reportable
    else
      @completion_report = CompletionReport.new
    end

    respond_to do |format|
      format.js 
      format.js.phone
    end
  end

  def create
    authorize @planning, :same_corporation_as_current_user?
    
    @completion_report = CompletionReport.new(completion_report_params)
    @completion_report.reportable = @reportable
    @completion_report.planning = @reportable.planning 
    @completion_report.patient = @reportable.patient
    
    @completion_report.save 
  end
  
  def update
    authorize @planning, :same_corporation_as_current_user?

    @completion_report.update(completion_report_params)
  end

  def edit
    respond_to do |format|
      format.js 
      format.js.phone
    end
  end

  def index
    if params[:m].present? && params[:y].present?
      range_start = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0).beginning_of_month
      last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59).end_of_month
      range_end = (Time.current + 10.hours) < last_day ? (Time.current + 10.hours) : last_day
    elsif params[:day].present?
      day = params[:day].to_date rescue nil 
      range_start = day.try(:beginning_of_day)
      range_end = day.try(:end_of_day)
    end

    @appointments_without_reports = Appointment.left_outer_joins(:completion_report).where(completion_reports: {id: nil}).includes(:nurse, :patient).operational.where('appointments.starts_at between ? and ?', range_start, range_end).order(starts_at: :desc)
    @recent_completion_reports = CompletionReport.includes(reportable: [:nurse, :patient]).from_appointments.joins('left join appointments on appointments.id = completion_reports.reportable_id').where('appointments.starts_at between ? and ?', range_start, range_end).order('appointments.starts_at desc')
    
    set_main_nurse if request.format.html?

    @appointments_without_reports = @appointments_without_reports.where(nurse_id: params[:nurse_id]) if params[:nurse_id].present?
    @appointments_without_reports = @appointments_without_reports.where(patient_id: params[:patient_id]) if params[:patient_id].present?
    @appointments_without_reports = @appointments_without_reports.where(nurse_id: @main_nurse.id) if @main_nurse.present?
    @recent_completion_reports = @recent_completion_reports.where('appointments.nurse_id = ?', params[:nurse_id]) if params[:nurse_id].present?
    @recent_completion_reports = @recent_completion_reports.where('appointments.nurse_id = ?', @main_nurse.id) if @main_nurse.present?
    @recent_completion_reports = @recent_completion_reports.where('appointments.patient_id = ?', params[:patient_id]) if params[:patient_id].present?
  end

  def destroy
    @completion_report.destroy
  end

  private

  def set_reportable
    if params[:appointment_id].present? 
      @reportable = Appointment.find(params[:appointment_id])
    elsif params[:recurring_appointment_id].present? 
      @reportable = RecurringAppointment.find(params[:recurring_appointment_id])
    end
  end

  def set_completion_report
    @completion_report = CompletionReport.find(params[:id])
  end

  def completion_report_params
    params.require(:completion_report).permit!
  end

end
