class PatientsController < ApplicationController
  before_action :set_corporation

  def index
  	@patients = @corporation.patients.all
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
  	@planning = Planning.find(params[:planning_id])
  	@patient = Patient.find(params[:id])
  end

  private

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end
end
