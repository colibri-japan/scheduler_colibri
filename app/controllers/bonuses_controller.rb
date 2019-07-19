class BonusesController < ApplicationController

  before_action :set_corporation

  def new
    @salary_rule = SalaryRule.new
    @salary_line_item = SalaryLineItem.new 
    @nurse = Nurse.find(params[:nurse_id])
    @services = @corporation.services.where(nurse_id: nil)
    @nurses = @corporation.nurses.displayable
  end

end
