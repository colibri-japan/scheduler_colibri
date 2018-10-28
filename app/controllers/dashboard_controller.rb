class DashboardController < ApplicationController
  before_action :set_corporation


  def index
    @plannings = @corporation.plannings.where(archived: false).order(created_at: :desc)
    @activities = PublicActivity::Activity.where(planning_id: @plannings.ids, created_at: current_user.last_sign_in_at..current_user.current_sign_in_at)
    @unseen_activity_count = @activities.count
    if @unseen_activity_count == 0
      @activities = PublicActivity::Activity.where(planning_id: @plannings.ids).last(5)
    end
    monthly_appointments = Appointment.where(planning_id: @plannings.ids, starts_at: Date.today.beginning_of_month..Date.today.end_of_day, master: false, displayable: true, deactivated: false).includes(:patient, :nurse)
    appointments = monthly_appointments.where(starts_at: Date.today.beginning_of_day..Date.today.end_of_day)
    
    monthly_provided_services = ProvidedService.where(planning_id: @plannings.ids, service_date: Date.today.beginning_of_month..Date.today, provided: true, temporary: false, deactivated: false).includes(:patient, :nurse)
    weekly_provided_services = monthly_provided_services.where(service_date: (Date.today - 7.days)..Date.today)
   
    @monthly_appointments_grouped_by_title = monthly_appointments.group_by {|e| e.title}
    @appointments_grouped_by_title = appointments.group_by {|e| e.title}
    @female_patients_ids = @corporation.patients.where(gender: true).ids 
    @male_patients_ids = @corporation.patients.where(gender: false).ids
    @provided_service_data = weekly_provided_services.group_by_day(:service_date).sum(:total_wage)

    #edit requested appointments for next two weeks
    today = Date.today.beginning_of_day
    @edit_requested_appointments = Appointment.where(planning_id: @plannings.ids, starts_at: today..(today + 15.days), edit_requested: true).order(starts_at: :asc)

    #appointments with comments for the next two weeks
    @commented_appointments = Appointment.where(planning_id: @plannings.ids, starts_at: today..(today + 15.days)).where.not(description: [nil, '']).order(starts_at: :asc)
    
    #posts
    @posts = @corporation.posts.order(created_at: :desc).first(10)
    
    @provided_service_duration_sums = weekly_provided_services.group_by_day(:service_date).sum(:service_duration)
    @provided_service_duration_sums.each do |service_date, total_duration|
      total_duration = total_duration / 60
    end
    @appointments = appointments.order(starts_at: :asc).group_by {|appointment| appointment.nurse_id}
  end

  private

  def set_corporation
    @corporation = current_user.corporation
  end
end
