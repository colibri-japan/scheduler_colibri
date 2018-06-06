class NursesController < ApplicationController
  before_action :set_corporation

  def index
  	@nurses = @corporation.nurses.all
  end

  private

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end
end
