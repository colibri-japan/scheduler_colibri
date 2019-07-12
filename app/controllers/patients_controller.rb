class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, except: [:index, :create, :new]
  before_action :set_planning, only: [:show, :master, :payable]
  before_action :set_printing_option, only: [:show, :master]
  before_action :set_caveats, only: [:new, :edit]

  def index
    if params[:start].present? && params[:end].present? && params[:master] == 'false' && params[:planning_id].to_i == @corporation.planning.id
      @patients = @corporation.patients.active.joins(:appointments).where(appointments: {master: false, archived_at: nil, planning_id: params[:planning_id], starts_at: params[:start].to_date.beginning_of_day..params[:end].to_date.beginning_of_day}).order_by_kana
    elsif params[:start].present? && params[:end].present? && params[:master] == 'true' && params[:planning_id].to_i == @corporation.planning.id
      patient_ids_from_recurring_appointments = RecurringAppointment.where(planning_id: params[:planning_id]).not_archived.from_master.not_terminated_at(params[:start].to_date).occurs_in_range(params[:start].to_date.beginning_of_day..(params[:end].to_date - 1.day).beginning_of_day).pluck(:patient_id).uniq
      @patients = @corporation.patients.active.where(id: patient_ids_from_recurring_appointments).order_by_kana
    else
      @patients = @corporation.cached_active_patients_grouped_by_kana
      @deactivated_patients = @corporation.cached_inactive_patients_ordered_by_kana
      @planning = @corporation.planning
      set_main_nurse
    end

    @planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
    
    if stale?(@patients)
      respond_to do |format|
        format.html
        format.json {render json: @patients.as_json}
        format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"利用者一覧_#{Date.today.strftime('%Y年%-m月%-d日')}.xlsx\""}
      end
    end
  end

  def show
    authorize @patient, :same_corporation_as_current_user?
    
    @patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
    fetch_nurses_grouped_by_team

    @recurring_appointments = RecurringAppointment.where(patient_id: @patient.id, planning_id: @planning.id, displayable: true)

    @nurses_with_services = Nurse.joins(:provided_services).select("nurses.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {patient_id: @patient.id}).where(displayable: true).group('nurses.id').order('sum_service_duration DESC')

  end

  def master
    authorize @planning, :same_corporation_as_current_user?

    @patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
    fetch_nurses_grouped_by_team
  end

  def edit
    set_nurses
    set_care_managers
  end

  def toggle_active
    @patient.toggle(:active)
    @patient.toggled_active_at = Time.now 

    if @patient.save(validate: false)
      CancelPatientAppointmentsWorker.perform_async(@patient.id)
      redirect_to patients_path, notice: '利用者のサービスが停止されました。'
    end
  end

  def new
    @patient = Patient.new
    set_nurses
    set_care_managers
  end

  def create
    params = patient_params
    params = convert_wareki_dates(params) 

    @patient = Patient.new(params)
    @patient.corporation_id = @corporation.id

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: '利用者様が登録されました' }
      else
        format.html { redirect_to patients_path, alert: '利用者様の登録が失敗しました' }
      end
    end
  end
  
  def update
    params = patient_params
    params = convert_wareki_dates(params)

    respond_to do |format|
      if @patient.update(params)
        format.js
        format.html { redirect_back(fallback_location: authenticated_root_path, notice: '利用者様の情報がアップデートされました') }
      else
        format.html { redirect_back(fallback_location: authenticated_root_path, alert: '利用者様の情報のアップデートが失敗しました') }
      end
    end
  end

  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: '利用者が削除されました' }
      format.json { head :no_content }
      format.js
    end
  end

  def new_master_to_schedule
    authorize current_user, :has_admin_access?
  end

  def master_to_schedule
    authorize current_user, :has_admin_access?

    @planning = @corporation.planning
    CopyPatientPlanningFromMasterWorker.perform_async(@patient.id, params[:month], params[:year])

    @planning.create_activity :reflect_patient_master, owner: current_user, planning_id: @planning.id, parameters: {year: params[:year].to_i, month: params[:month].to_i, patient_id: @patient.id, patient_name: @patient.try(:name)}

    redirect_to planning_patient_path(@planning, @patient), notice: "#{@patient.name}様のサービスの反映が始まりました。数秒後リフレッシュしてください"
  end

  def payable 
    authorize current_user, :has_access_to_provided_services?
    authorize @patient, :same_corporation_as_current_user?

    set_month_and_year_params
    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana

    @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
    @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
    @end_of_today_in_japan = (Time.current + 9.hours).end_of_day < @last_day ? (Time.current + 9.hours).end_of_day : @last_day

    @services_from_appointments = ProvidedService.not_archived.in_range(@first_day..@end_of_today_in_japan).from_appointments.includes(:appointment, :nurse).where(patient_id: @patient.id, planning_id: @planning.id).order(service_date: 'asc')
    
    @provided_service_summary = @patient.provided_service_summary(@first_day..@end_of_today_in_japan, within_insurance_scope: true)
    @provided_service_summary_without_insurance = @patient.provided_service_summary(@first_day..@end_of_today_in_japan, within_insurance_scope: false)
    @cancelled_but_invoiceable_services = @services_from_appointments.where(cancelled: true).where.not(invoiced_total: [0, nil])

    calculate_invoice_fields

    respond_to do |format|
      format.html 
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"請求書_#{@patient.try(:name)}様_#{params[:y]}年#{params[:m]}月.xlsx\""}
    end
  end

  def commented_appointments
    authorize current_user, :has_admin_access?
    authorize @patient, :same_corporation_as_current_user?
    
    if params[:m].present? && params[:y].present?
      @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0, 0)
      @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59, 59)
      
      @commented_appointments = Appointment.commented.edit_not_requested.not_archived.where(patient_id: @patient.id).in_range(@first_day..@last_day).order(:starts_at)
      
      respond_to do |format|
        format.html 
        format.pdf do
          render pdf: "#{@patient.name}様_サービス編集内容_#{@first_day.strftime('%Jy年%Jm月')}分",
          page_size: 'A4',
          layout: 'pdf.html',
          orientation: 'portrait',
          encoding: 'UTF-8',
          zoom: 1,
          dpi: 75
        end 
      end
    else
      redirect_back fallback_location: authenticated_root_path
    end
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def set_planning 
    @planning = Planning.find(params[:planning_id])
  end

  def set_caveats
    @caveats = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Patient', taggable_id: @corporation.patients.ids, context: 'caveats'})
  end

  def set_printing_option
    @printing_option = @corporation.printing_option
  end

  def set_nurses
    @nurses = @corporation.nurses.displayable.order_by_kana
  end

  def set_care_managers
    care_manager_corporation_ids = @corporation.care_manager_corporations.ids
    @care_managers = CareManager.where(care_manager_corporation_id: care_manager_corporation_ids).includes(:care_manager_corporation).order(:care_manager_corporation_id)
  end
  
  def set_month_and_year_params
    @selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
  end

  def calculate_invoice_fields
    @sum_of_credits = @provided_service_summary.sum {|hash| hash[:sum_total_credits]}
    @bonus_credits = (@sum_of_credits * (@corporation.invoicing_bonus_ratio - 1)).round
    @total_credits = @bonus_credits.present? ? @sum_of_credits + @bonus_credits : (@sum_of_credits || 0)
    @total_invoiced_inside_insurance_scope = (@total_credits * @corporation.credits_to_jpy_ratio).floor
    @credits_within_max_budget = @total_credits > @patient.current_max_credits ? @patient.current_max_credits : @total_credits
    @credits_exceeding_max_budget = @total_credits - @credits_within_max_budget
    @amount_invoiced_within_max_budget = (@credits_within_max_budget * @corporation.credits_to_jpy_ratio).floor
    @amount_invoiced_to_insurance_within_max_budget = (@amount_invoiced_within_max_budget * ((10 - (@patient.ratio_paid_by_patient || 0)) * 0.1)).floor
    @amount_invoiced_to_patient_within_max_budget = @amount_invoiced_within_max_budget - @amount_invoiced_to_insurance_within_max_budget
    @amount_invoiced_exceeding_max_budget = @total_invoiced_inside_insurance_scope - @amount_invoiced_within_max_budget 
    @total_invoiced_to_patient_inside_insurance_scope = @amount_invoiced_to_patient_within_max_budget + @amount_invoiced_exceeding_max_budget
    @total_invoiced_outside_insurance_scope = @provided_service_summary_without_insurance.sum {|hash| hash[:sum_invoiced_total]} + @cancelled_but_invoiceable_services.sum(:invoiced_total)
    @total_invoiced_to_patient = @total_invoiced_to_patient_inside_insurance_scope + @total_invoiced_outside_insurance_scope
    @total_sales = @total_invoiced_outside_insurance_scope + @total_invoiced_inside_insurance_scope
  end

  def convert_wareki_dates(params)
    params[:kaigo_certification_date] = Date.parse(params[:kaigo_certification_date]) rescue nil
    params[:kaigo_certification_validity_end] = Date.parse(params[:kaigo_certification_validity_end]) rescue nil
    params[:kaigo_certification_validity_start] = Date.parse(params[:kaigo_certification_validity_start]) rescue nil
    params[:birthday] = Date.parse(params[:birthday]) rescue nil
    params
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address, :gender, :description, :handicap_level, :kaigo_level, :nurse_id, :doctor_name, :care_manager_name, :care_manager_id, :date_of_contract, :insurance_id, :birthday, :kaigo_certification_date, :kaigo_certification_validity_start, :kaigo_certification_validity_end, :ratio_paid_by_patient, :public_assistance_id_1, :public_assistance_receiver_number_1, :public_assistance_id_2, :public_assistance_receiver_number_2, :end_of_contract, :issuing_administration_number, :issuing_administration_name, insurance_policy: [], caveat_list:[])
  end
end
