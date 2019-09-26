class CompletionReportsController < ApplicationController

  before_action :set_corporation
  before_action :set_appointment, except: :index
  before_action :set_planning
  before_action :set_completion_report, only: [:update, :edit, :destroy]

  def new
    @completion_report = CompletionReport.new
  end

  def create
    authorize @planning, :same_corporation_as_current_user?
    
    @completion_report = CompletionReport.new(completion_report_params)
    @completion_report.appointment_id = @appointment.id
    
    @completion_report.save 
  end
  
  def update
    authorize @planning, :same_corporation_as_current_user?

    @completion_report.update(completion_report_params)
  end

  def edit
  end

  def index
    now_in_japan = Time.current.in_time_zone('Tokyo')
    @appointments_without_reports = Appointment.left_outer_joins(:completion_report).includes(:nurse, :patient).where('appointments.starts_at between ? and ?', (now_in_japan - 7.days), now_in_japan).limit(20)
    @recent_completion_reports = CompletionReport.includes(appointment: [:nurse, :patient]).joins(:appointment).where('appointments.starts_at between ? and ?', (now_in_japan - 7.days), now_in_japan).limit(20)
    
    @appointments_without_reports = @appointments_without_reports.where(nurse_id: params[:nurse_id]) if params[:nurse_id].present?
    @appointments_without_reports = @appointments_without_reports.where(patient_id: params[:patient_id]) if params[:patient_id].present?
    @recent_completion_reports = @recent_completion_reports.where('appointments.nurse_id = ?', params[:nurse_id]) if params[:nurse_id].present?
    @recent_completion_reports = @recent_completion_reports.where('appointments.patient_id = ?', params[:patient_id]) if params[:patient_id].present?
  end

  def destroy
    @completion_report.destroy
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:appointment_id])
    @nurse = @appointment.nurse
  end

  def set_completion_report
    @completion_report = CompletionReport.find(params[:id])
  end

  def completion_report_params
    params.require(:completion_report).permit!
  end

end
