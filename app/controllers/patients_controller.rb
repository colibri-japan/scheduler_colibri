class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def index
  	@patients = @corporation.patients.all.order_by_kana
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
    @planning = Planning.find(params[:planning_id])
    authorize @patient, :is_employee?
    
    @patients = @corporation.patients.all.order_by_kana
    @last_patient = @corporation.patients.last
    @nurses = @corporation.nurses.where.not(name: '未定').order_by_kana
    @last_nurse = @nurses.last
    @activities = PublicActivity::Activity.where(planning_id: @planning.id, patient_id: @patient.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
    @recurring_appointments = RecurringAppointment.where(patient_id: @patient.id, planning_id: @planning.id, displayable: true)

    set_valid_range
  end

  def edit
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)
    @patient.corporation_id = @corporation.id

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: '利用者がセーブされました' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html {redirect_to patients_path, notice: '利用者の情報がアップデートされました' }
      else
        format.html {render :edit}
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



  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def set_valid_range
    valid_month = @planning.business_month
    valid_year = @planning.business_year
    @start_valid = Date.new(valid_year, valid_month, 1).strftime("%Y-%m-%d")
    @end_valid = Date.new(valid_year, valid_month +1, 1).strftime("%Y-%m-%d")
  end

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address)
  end
end
