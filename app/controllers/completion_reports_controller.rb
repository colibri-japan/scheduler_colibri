class CompletionReportsController < ApplicationController

  before_action :set_corporation
  before_action :set_appointment
  before_action :set_planning

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

    @completion_report = CompletionReport.find(params[:id])

    @completion_report.update(completion_report_params)
  end

  def edit
      @completion_report = CompletionReport.find(params[:id])
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:appointment_id])
    @nurse = @appointment.nurse
  end

  def set_planning
    @planning = @appointment.planning
  end

  def completion_report_params
    params.require(:completion_report).permit!
  end

end
