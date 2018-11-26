class ScanController < ApplicationController

  before_action :set_planning, only: [:index, :new, :create]
  before_action :set_scan, only: [:edit, :update, :destroy]

  def index
    @scans = @planning.scans
  end

  def new
    @scan = Scan.new
  end

  def create
    @scan = Scan.new 

    @scan.create(scan_params)
  end

  def edit
    @planning = Planning.find(:planning_id)
  end

  def update
    @planning = Planning.find(:planning_id)

    @scan.update(scan_params)
  end

  def destroy
    @planning = Planning.find(:planning_id)

    @scan.destroy
  end

  private

  def scan_params
    params.require(:scan).permit(:teikyohyo)
  end

  def set_planning
    @planning = Planning.find(:id)
  end

  def set_scan 
    @scan = Scan.find(:id)
  end

end
